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
    Player
  }
  alias JetLagServerWeb.Endpoint

  @doc """
  Broadcasts a player_joined event to all clients connected to the game's channel.
  """
  @spec broadcast_player_joined(String.t(), %Player{}) :: :ok
  def broadcast_player_joined(game_id, player) do
    Endpoint.broadcast("games:#{game_id}", "player_joined", %PlayerJoinedEvent{
      player: player
    })
  end

  @doc """
  Broadcasts a player_left event to all clients connected to the game's channel.
  """
  @spec broadcast_player_left(String.t(), String.t()) :: :ok
  def broadcast_player_left(game_id, player_id) do
    Endpoint.broadcast("games:#{game_id}", "player_left", %PlayerLeftEvent{
      player_id: player_id
    })
  end

  @doc """
  Broadcasts a game_started event to all clients connected to the game's channel.
  """
  @spec broadcast_game_started(String.t(), DateTime.t() | NaiveDateTime.t()) :: :ok
  def broadcast_game_started(game_id, started_at) do
    Endpoint.broadcast("games:#{game_id}", "game_started", %GameStartedEvent{
      started_at: started_at
    })
  end
end
