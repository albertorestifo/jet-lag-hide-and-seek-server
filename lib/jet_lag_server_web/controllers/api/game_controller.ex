defmodule JetLagServerWeb.API.GameController do
  use JetLagServerWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias JetLagServer.Games
  alias JetLagServer.Games.Game
  alias JetLagServerWeb.Schemas
  alias OpenApiSpex.Schema

  action_fallback JetLagServerWeb.FallbackController

  tags(["games"])

  operation(:create,
    summary: "Create a new game",
    description: "Creates a new game with the specified settings",
    request_body: {"Game creation parameters", "application/json", Schemas.CreateGameRequest},
    responses: [
      created: {"Game created successfully", "application/json", Schemas.CreateGameResponse},
      bad_request: {"Invalid request", "application/json", Schemas.Error},
      internal_server_error: {"Server error", "application/json", Schemas.Error}
    ]
  )

  def create(conn, %{
        "location" => location_params,
        "settings" => settings_params,
        "creator" => creator_params
      }) do
    with {:ok, game} <-
           Games.create_game(%{
             location: location_params,
             settings: settings_params,
             creator: creator_params
           }) do
      # Generate a token for WebSocket authentication
      token = Games.generate_token(game.id, List.first(game.players).id)

      conn
      |> put_status(:created)
      |> put_resp_header("location", "/api/games/#{game.id}")
      |> render(:created, game: game, token: token)
    end
  end

  operation(:show,
    summary: "Get game details",
    description: "Retrieves details about a specific game",
    parameters: [
      id: [
        in: :path,
        description: "Game ID",
        type: :string,
        example: "game-123",
        required: true
      ]
    ],
    responses: [
      ok:
        {"Game details retrieved successfully", "application/json",
         %Schema{type: :object, properties: %{data: Schemas.Game}}},
      not_found: {"Game not found", "application/json", Schemas.Error},
      internal_server_error: {"Server error", "application/json", Schemas.Error}
    ]
  )

  def show(conn, %{"id" => id}) do
    with %Game{} = game <- Games.get_game(id) do
      render(conn, :show, game: game)
    else
      nil -> {:error, :not_found}
    end
  end

  operation(:start,
    summary: "Start a game",
    description: "Starts a game, preventing new players from joining",
    parameters: [
      id: [
        in: :path,
        description: "Game ID",
        type: :string,
        example: "game-123",
        required: true
      ]
    ],
    responses: [
      ok:
        {"Game started successfully", "application/json",
         %Schema{type: :object, properties: %{data: Schemas.Game}}},
      not_found: {"Game not found", "application/json", Schemas.Error},
      internal_server_error: {"Server error", "application/json", Schemas.Error}
    ]
  )

  def start(conn, %{"id" => id}) do
    with %Game{} = game <- Games.get_game(id),
         {:ok, game} <- Games.start_game(game) do
      # Broadcast to all connected clients that the game has started
      JetLagServerWeb.Endpoint.broadcast(
        "games:#{game.id}",
        "game_started",
        %JetLagServer.Games.Structs.GameStartedEvent{
          started_at: game.started_at
        }
      )

      render(conn, :show, game: game)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  operation(:join,
    summary: "Join a game",
    description: "Allows a player to join an existing game using a game code",
    request_body: {"Game join parameters", "application/json", Schemas.JoinGameRequest},
    responses: [
      ok: {"Successfully joined the game", "application/json", Schemas.JoinGameResponse},
      bad_request: {"Invalid request or game code", "application/json", Schemas.Error},
      not_found: {"Game not found", "application/json", Schemas.Error},
      internal_server_error: {"Server error", "application/json", Schemas.Error}
    ]
  )

  def join(conn, %{"game_code" => game_code, "player_name" => player_name}) do
    with %Game{} = game <- Games.get_game_by_code(game_code),
         {:ok, player} <- Games.add_player_to_game(game.id, player_name) do
      # Generate a token for WebSocket authentication
      token = Games.generate_token(game.id, player.id)

      # Broadcast to all connected clients that a new player has joined
      player_struct = JetLagServer.Games.Structs.Player.from_schema(player)

      JetLagServerWeb.Endpoint.broadcast(
        "games:#{game.id}",
        "player_joined",
        %JetLagServer.Games.Structs.PlayerJoinedEvent{
          player: player_struct
        }
      )

      # Get the updated game with the new player
      game = Games.get_game(game.id)

      conn
      |> render(:joined, game: game, player: player, token: token)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end
end
