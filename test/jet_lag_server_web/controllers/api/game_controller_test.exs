defmodule JetLagServerWeb.API.GameControllerTest do
  use JetLagServerWeb.ConnCase

  import JetLagServer.GamesFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create game" do
    test "renders game when data is valid", %{conn: conn} do
      valid_attrs = %{
        location: %{
          name: "Madrid",
          type: "City",
          coordinates: [-3.7038, 40.4168],
          bounding_box: [-3.8, 40.3, -3.6, 40.5],
          osm_id: "12345678",
          osm_type: "way"
        },
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

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{
        location: %{
          # Missing name and coordinates
          type: "City",
          osm_id: "12345678",
          osm_type: "way"
        },
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
      assert json_response(conn, 400)["code"] == "validation_error"
    end
  end

  describe "show game" do
    setup [:create_game]

    test "renders game when game exists", %{conn: conn, game: game} do
      conn = get(conn, ~p"/api/games/#{game.id}")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == game.id
      assert data["code"] == game.code
      assert data["status"] == "waiting"
      assert data["location"]["name"] == "Madrid"
      assert data["settings"]["units"] == "iso"
      assert [player] = data["players"]
      assert player["name"] == "John Doe"
      assert player["is_creator"] == true
    end

    test "renders 404 when game does not exist", %{conn: conn} do
      conn = get(conn, ~p"/api/games/#{Ecto.UUID.generate()}")
      assert json_response(conn, 404)["errors"]["detail"] == "Not Found"
    end
  end

  describe "start game" do
    setup [:create_game]

    test "renders game when game exists", %{conn: conn, game: game} do
      conn = post(conn, ~p"/api/games/#{game.id}/start")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == game.id
      assert data["status"] == "active"
      assert data["started_at"] != nil
    end

    test "renders 404 when game does not exist", %{conn: conn} do
      conn = post(conn, ~p"/api/games/#{Ecto.UUID.generate()}/start")
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
end
