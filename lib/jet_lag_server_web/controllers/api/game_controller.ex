defmodule JetLagServerWeb.API.GameController do
  use JetLagServerWeb, :controller

  alias JetLagServer.Games
  alias JetLagServer.Games.Game

  action_fallback JetLagServerWeb.FallbackController

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

  def show(conn, %{"id" => id}) do
    with %Game{} = game <- Games.get_game(id) do
      render(conn, :show, game: game)
    else
      nil -> {:error, :not_found}
    end
  end

  def start(conn, %{"id" => id}) do
    with %Game{} = game <- Games.get_game(id),
         {:ok, game} <- Games.start_game(game) do
      # Broadcast to all connected clients that the game has started
      JetLagServerWeb.Endpoint.broadcast("games:#{game.id}", "game_started", %{
        startedAt: game.started_at
      })

      render(conn, :show, game: game)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def join(conn, %{"gameCode" => game_code, "playerName" => player_name}) do
    with %Game{} = game <- Games.get_game_by_code(game_code),
         {:ok, player} <- Games.add_player_to_game(game.id, player_name) do
      # Generate a token for WebSocket authentication
      token = Games.generate_token(game.id, player.id)

      # Broadcast to all connected clients that a new player has joined
      JetLagServerWeb.Endpoint.broadcast("games:#{game.id}", "player_joined", %{
        player: %{
          id: player.id,
          name: player.name,
          isCreator: player.is_creator
        }
      })

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
