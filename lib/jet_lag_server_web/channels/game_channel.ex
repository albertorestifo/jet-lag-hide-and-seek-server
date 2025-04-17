defmodule JetLagServerWeb.GameChannel do
  use JetLagServerWeb, :channel
  alias JetLagServer.Games

  @doc """
  Joins a game channel.
  """
  def join("games:" <> game_id, %{"token" => token}, socket) do
    case Games.verify_token(token, game_id) do
      {:ok, player_id} ->
        socket = assign(socket, :player_id, player_id)
        socket = assign(socket, :game_id, game_id)

        # Get the game to send as initial state
        game = Games.get_game(game_id)

        # Find the current player
        player = Enum.find(game.players, fn p -> p.id == player_id end)

        {:ok, game_data(game), assign(socket, :is_creator, player.is_creator)}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  def join("games:" <> _game_id, _params, _socket) do
    {:error, %{reason: "authentication required"}}
  end

  # Handle different incoming messages
  def handle_in("join_game", %{"playerName" => player_name}, socket) do
    game_id = socket.assigns.game_id

    case Games.add_player_to_game(game_id, player_name) do
      {:ok, player} ->
        # Broadcast to all connected clients that a new player has joined
        broadcast!(socket, "player_joined", %{
          player: %{
            id: player.id,
            name: player.name,
            isCreator: player.is_creator
          }
        })

        {:reply, {:ok, %{playerId: player.id}}, socket}

      _error ->
        {:reply, {:error, %{reason: "failed to join game"}}, socket}
    end
  end

  def handle_in("leave_game", _params, socket) do
    player_id = socket.assigns.player_id

    case Games.remove_player_from_game(player_id) do
      {:ok, _} ->
        # Broadcast to all connected clients that a player has left
        broadcast!(socket, "player_left", %{
          playerId: player_id
        })

        {:stop, :normal, socket}

      _error ->
        {:reply, {:error, %{reason: "failed to leave game"}}, socket}
    end
  end

  def handle_in("start_game", _params, socket) do
    if socket.assigns.is_creator do
      game_id = socket.assigns.game_id
      game = Games.get_game(game_id)

      case Games.start_game(game) do
        {:ok, updated_game} ->
          # Broadcast to all connected clients that the game has started
          broadcast!(socket, "game_started", %{
            startedAt: updated_game.started_at
          })

          {:reply, {:ok, %{startedAt: updated_game.started_at}}, socket}

        _error ->
          {:reply, {:error, %{reason: "failed to start game"}}, socket}
      end
    else
      {:reply, {:error, %{reason: "only the creator can start the game"}}, socket}
    end
  end

  def handle_in("ping", _params, socket) do
    {:reply, {:ok, %{type: "pong", data: %{}}}, socket}
  end

  @doc """
  Handles channel termination.
  """
  def terminate(_reason, _socket) do
    # If we want to do any cleanup when a client disconnects
    :ok
  end

  # Helper function to format game data for the channel
  defp game_data(game) do
    %{
      id: game.id,
      code: game.code,
      location: %{
        name: game.location.name,
        type: game.location.type,
        coordinates: game.location.coordinates,
        boundingBox: game.location.bounding_box,
        osmId: game.location.osm_id,
        osmType: game.location.osm_type
      },
      settings: %{
        units: game.settings.units,
        hidingZones: game.settings.hiding_zones,
        hidingZoneSize: game.settings.hiding_zone_size,
        gameDuration: game.settings.game_duration,
        dayStartTime: game.settings.day_start_time,
        dayEndTime: game.settings.day_end_time
      },
      players:
        Enum.map(game.players, fn player ->
          %{
            id: player.id,
            name: player.name,
            isCreator: player.is_creator
          }
        end),
      status: game.status,
      createdAt: game.inserted_at,
      startedAt: game.started_at
    }
  end
end
