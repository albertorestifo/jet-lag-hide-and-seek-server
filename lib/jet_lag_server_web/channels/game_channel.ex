defmodule JetLagServerWeb.GameChannel do
  use JetLagServerWeb, :channel
  alias JetLagServer.Games
  alias JetLagServer.Games.Structs

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

        # Assign is_creator to the socket
        socket = assign(socket, :is_creator, player.is_creator)

        # Convert the game to a struct for the response
        game_struct = Structs.Game.from_schema(game)

        # Send the current game state to the client
        # This is especially useful for reconnections after app restart
        send(self(), {:after_join, game_struct})

        {:ok, game_struct, socket}

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
        {:reply, {:ok, %{player_id: player.id}}, socket}

      _error ->
        {:reply, {:error, %{reason: "failed to join game"}}, socket}
    end
  end

  def handle_in("leave_game", _params, socket) do
    player_id = socket.assigns.player_id

    case Games.remove_player_from_game(player_id) do
      {:ok, _} ->
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
          {:reply, {:ok, %{started_at: updated_game.started_at}}, socket}

        _error ->
          {:reply, {:error, %{reason: "failed to start game"}}, socket}
      end
    else
      {:reply, {:error, %{reason: "only the creator can start the game"}}, socket}
    end
  end

  def handle_in("ping", _params, socket) do
    {:reply, {:ok, %Structs.PongEvent{}}, socket}
  end

  @doc """
  Handles the after_join message to send the game state to the client.
  This is especially useful for reconnections after app restart.
  """
  def handle_info({:after_join, game}, socket) do
    # Push the game state directly to the client
    # This is more reliable than broadcasting and easier to test
    push(socket, "game_state", %JetLagServer.Games.Structs.GameUpdatedEvent{
      game: game
    })

    {:noreply, socket}
  end

  @doc """
  Handles channel termination.
  """
  def terminate(_reason, _socket) do
    # If we want to do any cleanup when a client disconnects
    :ok
  end
end
