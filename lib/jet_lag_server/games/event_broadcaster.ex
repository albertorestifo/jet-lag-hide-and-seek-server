defmodule JetLagServer.Games.EventBroadcaster do
  @moduledoc """
  Handles broadcasting of game events to connected clients.
  This module centralizes all event broadcasting logic to avoid duplication
  between HTTP controllers and WebSocket channels.
  """

  alias JetLagServer.Games.Structs.{
    PlayerJoinedEvent,
    PlayerLeftEvent,
    GameStartedEvent,
    GameUpdatedEvent,
    GameDeletedEvent,
    Player,
    Game
  }

  alias JetLagServerWeb.Endpoint
  alias JetLagServerWeb.WebSocketLogger

  @doc """
  Broadcasts a player_joined event to all clients connected to the game's channel.
  """
  @spec broadcast_player_joined(String.t(), %Player{}) :: :ok
  def broadcast_player_joined(game_id, player) do
    topic = "games:#{game_id}"
    payload = %PlayerJoinedEvent{player: player}

    WebSocketLogger.log_broadcast_message(topic, "player_joined", payload)
    Endpoint.broadcast(topic, "player_joined", payload)
  end

  @doc """
  Broadcasts a player_left event to all clients connected to the game's channel.
  """
  @spec broadcast_player_left(String.t(), String.t()) :: :ok
  def broadcast_player_left(game_id, player_id) do
    topic = "games:#{game_id}"
    payload = %PlayerLeftEvent{player_id: player_id}

    WebSocketLogger.log_broadcast_message(topic, "player_left", payload)
    Endpoint.broadcast(topic, "player_left", payload)
  end

  @doc """
  Broadcasts a game_started event to all clients connected to the game's channel.
  """
  @spec broadcast_game_started(String.t(), DateTime.t() | NaiveDateTime.t()) :: :ok
  def broadcast_game_started(game_id, started_at) do
    topic = "games:#{game_id}"
    payload = %GameStartedEvent{started_at: started_at}

    WebSocketLogger.log_broadcast_message(topic, "game_started", payload)
    Endpoint.broadcast(topic, "game_started", payload)
  end

  @doc """
  Broadcasts the current game state to a specific client.
  This is used when a client reconnects to the socket.
  """
  @spec broadcast_game_state(String.t(), Game.t()) :: :ok
  def broadcast_game_state(topic, game) do
    payload = %GameUpdatedEvent{game: game}

    WebSocketLogger.log_broadcast_message(topic, "game_state", payload)
    Endpoint.broadcast(topic, "game_state", payload)
  end

  @doc """
  Broadcasts a game_deleted event to all clients connected to the game's channel.
  This is used when a game is deleted to notify clients to disconnect.
  """
  @spec broadcast_game_deleted(String.t(), String.t()) :: :ok
  def broadcast_game_deleted(game_id, reason \\ "Game deleted by creator") do
    topic = "games:#{game_id}"
    payload = %GameDeletedEvent{game_id: game_id, reason: reason}

    WebSocketLogger.log_broadcast_message(topic, "game_deleted", payload)
    Endpoint.broadcast(topic, "game_deleted", payload)
  end
end
