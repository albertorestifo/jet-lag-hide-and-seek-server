defmodule JetLagServerWeb.API.GameControllerTest do
  use JetLagServerWeb.ConnCase

  import JetLagServer.GamesFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create game" do
    setup do
      # Create a cached boundary in the database that we can reference by ID
      cached = JetLagServer.GamesFixtures.cached_boundary_fixture()

      %{cached: cached}
    end

    test "renders game when data is valid", %{conn: conn, cached: cached} do
      valid_attrs = %{
        location_id: "#{cached.osm_type}:#{cached.osm_id}",
        settings: %{
          units: "iso",
          hiding_zones: ["bus_stops", "local_trains"],
          hiding_zone_size: 500,
          game_duration: 1,
          day_start_time: "09:00",
          day_end_time: "18:00"
        },
        creator: %{
          name: "John Doe"
        }
      }

      conn = post(conn, ~p"/api/games", valid_attrs)

      assert %{"game_id" => game_id, "game_code" => game_code, "websocket_url" => websocket_url} =
               json_response(conn, 201)

      assert game_id =~ ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
      assert game_code =~ ~r/^[A-Z0-9]{6}$/
      assert websocket_url =~ ~r/^wss:\/\/localhost\/ws\/games\/#{game_id}\?token=/
    end

    test "renders error when location does not exist", %{conn: conn} do
      invalid_attrs = %{
        # Non-existent location
        location_id: "way:999999",
        settings: %{
          units: "iso",
          hiding_zones: ["bus_stops", "local_trains"],
          hiding_zone_size: 500,
          game_duration: 1,
          day_start_time: "09:00",
          day_end_time: "18:00"
        },
        creator: %{
          name: "John Doe"
        }
      }

      conn = post(conn, ~p"/api/games", invalid_attrs)
      assert json_response(conn, 400)["message"] == "Location not found"
    end

    test "renders error when location ID format is invalid", %{conn: conn} do
      invalid_attrs = %{
        # Invalid format
        location_id: "invalid-format",
        settings: %{
          units: "iso",
          hiding_zones: ["bus_stops", "local_trains"],
          hiding_zone_size: 500,
          game_duration: 1,
          day_start_time: "09:00",
          day_end_time: "18:00"
        },
        creator: %{
          name: "John Doe"
        }
      }

      conn = post(conn, ~p"/api/games", invalid_attrs)

      assert json_response(conn, 400)["message"] ==
               "Invalid location ID format. Expected format: osm_type:osm_id"
    end
  end

  describe "show game" do
    setup [:create_game_with_token]

    test "renders game when game exists", %{conn: conn, game: game, token: token} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/games/#{game.id}")

      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == game.id
      assert data["code"] == game.code
      assert data["status"] == "waiting"
      # The location name comes from the cached boundary
      assert data["settings"]["units"] == "iso"
      assert [player] = data["players"]
      assert player["name"] == "John Doe"
      assert player["is_creator"] == true
    end

    test "renders 401 when no token is provided", %{conn: conn, game: game} do
      conn = get(conn, ~p"/api/games/#{game.id}")
      assert json_response(conn, 401)["code"] == "unauthorized"
      assert json_response(conn, 401)["message"] == "Unauthorized"
    end

    test "renders 404 when game does not exist", %{conn: conn, token: token} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/games/#{Ecto.UUID.generate()}")

      assert json_response(conn, 404)["errors"]["detail"] == "Not Found"
    end
  end

  describe "start game" do
    setup [:create_game_with_token]

    test "renders game when game exists and user is creator", %{
      conn: conn,
      game: game,
      token: token
    } do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/games/#{game.id}/start")

      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == game.id
      assert data["status"] == "active"
      assert data["started_at"] != nil
    end

    test "renders 401 when no token is provided", %{conn: conn, game: game} do
      conn = post(conn, ~p"/api/games/#{game.id}/start")
      assert json_response(conn, 401)["code"] == "unauthorized"
      assert json_response(conn, 401)["message"] == "Unauthorized"
    end

    test "renders 403 when user is not the creator", %{conn: conn, game: game} do
      # Create a non-creator player
      {:ok, player} = JetLagServer.Games.add_player_to_game(game.id, "Not Creator")
      # Generate a token for this player
      non_creator_token = JetLagServer.Games.generate_token(game.id, player.id)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{non_creator_token}")
        |> post(~p"/api/games/#{game.id}/start")

      assert json_response(conn, 403)["code"] == "forbidden"
      assert json_response(conn, 403)["message"] == "Only the game creator can start the game"
    end

    test "renders 404 when game does not exist", %{conn: conn, token: token} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(~p"/api/games/#{Ecto.UUID.generate()}/start")

      assert json_response(conn, 404)["errors"]["detail"] == "Not Found"
    end
  end

  describe "join game" do
    setup [:create_game]

    test "renders game when game exists and join is successful", %{conn: conn, game: game} do
      conn =
        post(conn, ~p"/api/games/join", %{"game_code" => game.code, "player_name" => "Jane Smith"})

      assert %{
               "game_id" => game_id,
               "player_id" => player_id,
               "websocket_url" => websocket_url,
               "game" => game_data
             } = json_response(conn, 200)

      assert game_id == game.id
      assert player_id =~ ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
      assert websocket_url =~ ~r/^wss:\/\/localhost\/ws\/games\/#{game_id}\?token=/
      assert game_data["id"] == game.id
      assert game_data["code"] == game.code
      assert length(game_data["players"]) == 2
      assert Enum.any?(game_data["players"], fn p -> p["name"] == "Jane Smith" end)
    end

    test "broadcasts player_joined event when a player joins", %{conn: conn, game: game} do
      # Subscribe to the game channel
      JetLagServerWeb.Endpoint.subscribe("games:#{game.id}")

      # Join the game
      conn =
        post(conn, ~p"/api/games/join", %{"game_code" => game.code, "player_name" => "Jane Smith"})

      # Extract the player_id from the response
      %{"player_id" => player_id} = json_response(conn, 200)

      # Assert that we received a player_joined event
      assert_receive %Phoenix.Socket.Broadcast{
        event: "player_joined",
        payload: %JetLagServer.Games.Structs.PlayerJoinedEvent{
          player: %JetLagServer.Games.Structs.Player{
            id: ^player_id,
            name: "Jane Smith",
            is_creator: false
          }
        }
      }
    end

    test "renders 404 when game does not exist", %{conn: conn} do
      conn =
        post(conn, ~p"/api/games/join", %{"game_code" => "INVALID", "player_name" => "Jane Smith"})

      assert json_response(conn, 404)["errors"]["detail"] == "Not Found"
    end
  end

  describe "check game exists" do
    setup [:create_game]

    test "returns true when game exists", %{conn: conn, game: game} do
      conn = get(conn, ~p"/api/games/check/#{game.code}")
      assert %{"exists" => true, "game_id" => game_id} = json_response(conn, 200)
      assert game_id == game.id
    end

    test "returns false when game does not exist", %{conn: conn} do
      conn = get(conn, ~p"/api/games/check/INVALID")
      assert %{"exists" => false, "game_id" => nil} = json_response(conn, 200)
    end
  end

  defp create_game(_) do
    game = game_fixture()
    %{game: game}
  end

  defp create_game_with_token(_) do
    game = game_fixture()
    creator = List.first(game.players)
    token = JetLagServer.Games.generate_token(game.id, creator.id)
    %{game: game, token: token, creator: creator}
  end
end
