defmodule JetLagServerWeb.Plugs.AuthenticatePlayer do
  @moduledoc """
  Plug to authenticate a player using a token.
  """
  import Plug.Conn
  alias JetLagServer.Games

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         game_id <- get_game_id_from_path(conn) do
      # First check if the game exists
      case JetLagServer.Games.get_game(game_id) do
        nil ->
          # Game doesn't exist, return 404
          conn
          |> put_status(:not_found)
          |> Phoenix.Controller.put_view(JetLagServerWeb.ErrorJSON)
          |> Phoenix.Controller.render("404.json")
          |> halt()

        _game ->
          # Game exists, verify the token
          case Games.verify_token(token, game_id) do
            {:ok, player_id} ->
              player = Games.get_player(player_id)

              if player do
                conn
                |> assign(:current_player, player)
                |> assign(:game_id, game_id)
              else
                unauthorized(conn)
              end

            _error ->
              unauthorized(conn)
          end
      end
    else
      _ -> unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> Phoenix.Controller.put_view(JetLagServerWeb.ErrorJSON)
    |> Phoenix.Controller.render(:error, status: 401, message: "Unauthorized")
    |> halt()
  end

  # Extract game_id from the path params
  defp get_game_id_from_path(conn) do
    conn.path_params["id"]
  end
end
