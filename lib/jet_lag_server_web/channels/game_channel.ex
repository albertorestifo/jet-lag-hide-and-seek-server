defmodule JetLagServerWeb.GameChannel do
  use JetLagServerWeb, :channel
  alias JetLagServer.Games
  alias JetLagServer.Games.Structs
  alias JetLagServerWeb.WebSocketLogger

  @doc """
  Joins a game channel.
  """
  def join("games:" <> game_id, %{"token" => token} = params, socket) do
    WebSocketLogger.log_join_attempt("games:#{game_id}", params)

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

        WebSocketLogger.log_join_success("games:#{game_id}", socket, game_struct)
        {:ok, game_struct, socket}

      {:error, reason} ->
        WebSocketLogger.log_join_failure("games:#{game_id}", reason)
        {:error, %{reason: reason}}
    end
  end

  def join("games:" <> game_id, params, _socket) do
    WebSocketLogger.log_join_attempt("games:#{game_id}", params)
    WebSocketLogger.log_join_failure("games:#{game_id}", "authentication required")
    {:error, %{reason: "authentication required"}}
  end

  # Handle different incoming messages
  def handle_in("join_game", %{"playerName" => player_name} = payload, socket) do
    WebSocketLogger.log_incoming_message("join_game", payload, socket)
    game_id = socket.assigns.game_id

    case Games.add_player_to_game(game_id, player_name) do
      {:ok, player} ->
        response = %{player_id: player.id}
        WebSocketLogger.log_outgoing_message("join_game:reply", response, socket)
        {:reply, {:ok, response}, socket}

      _error ->
        response = %{reason: "failed to join game"}
        WebSocketLogger.log_outgoing_message("join_game:error", response, socket)
        {:reply, {:error, response}, socket}
    end
  end

  def handle_in("leave_game", payload, socket) do
    WebSocketLogger.log_incoming_message("leave_game", payload, socket)
    player_id = socket.assigns.player_id

    case Games.remove_player_from_game(player_id) do
      {:ok, _} ->
        WebSocketLogger.log_outgoing_message("leave_game:stop", %{reason: :normal}, socket)
        {:stop, :normal, socket}

      _error ->
        response = %{reason: "failed to leave game"}
        WebSocketLogger.log_outgoing_message("leave_game:error", response, socket)
        {:reply, {:error, response}, socket}
    end
  end

  def handle_in("start_game", payload, socket) do
    WebSocketLogger.log_incoming_message("start_game", payload, socket)

    if socket.assigns.is_creator do
      game_id = socket.assigns.game_id
      game = Games.get_game(game_id)

      case Games.start_game(game) do
        {:ok, updated_game} ->
          response = %{started_at: updated_game.started_at}
          WebSocketLogger.log_outgoing_message("start_game:reply", response, socket)
          {:reply, {:ok, response}, socket}

        _error ->
          response = %{reason: "failed to start game"}
          WebSocketLogger.log_outgoing_message("start_game:error", response, socket)
          {:reply, {:error, response}, socket}
      end
    else
      response = %{reason: "only the creator can start the game"}
      WebSocketLogger.log_outgoing_message("start_game:error", response, socket)
      {:reply, {:error, response}, socket}
    end
  end

  def handle_in("ping", payload, socket) do
    WebSocketLogger.log_incoming_message("ping", payload, socket)
    response = %Structs.PongEvent{}
    WebSocketLogger.log_outgoing_message("ping:reply", response, socket)
    {:reply, {:ok, response}, socket}
  end

  def handle_in(
        "update_location",
        %{"latitude" => latitude, "longitude" => longitude, "precision" => precision} = payload,
        socket
      ) do
    WebSocketLogger.log_incoming_message("update_location", payload, socket)
    player_id = socket.assigns.player_id

    case Games.update_player_location(player_id, latitude, longitude, precision) do
      {:ok, _location} ->
        WebSocketLogger.log_outgoing_message("update_location:reply", :ok, socket)
        {:reply, :ok, socket}

      {:error, reason} ->
        response = %{reason: reason}
        WebSocketLogger.log_outgoing_message("update_location:error", response, socket)
        {:reply, {:error, response}, socket}
    end
  end

  @doc """
  Handles the after_join message to send the game state to the client.
  This is especially useful for reconnections after app restart.
  """
  def handle_info({:after_join, game}, socket) do
    # Push the game state directly to the client
    # This is more reliable than broadcasting and easier to test
    event = %JetLagServer.Games.Structs.GameUpdatedEvent{
      game: game
    }

    WebSocketLogger.log_outgoing_message("game_state", event, socket)
    push(socket, "game_state", event)

    {:noreply, socket}
  end

  @doc """
  Handles channel termination.
  """
  def terminate(reason, socket) do
    # Log the termination
    WebSocketLogger.log_terminate(reason, socket)

    # If we want to do any cleanup when a client disconnects
    :ok
  end
end
