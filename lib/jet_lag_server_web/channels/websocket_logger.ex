defmodule JetLagServerWeb.WebSocketLogger do
  @moduledoc """
  Provides logging functions for WebSocket communication.
  """
  
  require Logger

  @doc """
  Logs a WebSocket connection attempt.
  """
  def log_connect(params, connect_info) do
    Logger.info("WebSocket CONNECT attempt with params: #{inspect(params, pretty: true)}, connect_info: #{inspect(connect_info, limit: :infinity)}")
  end

  @doc """
  Logs a successful WebSocket connection.
  """
  def log_connect_success(socket) do
    Logger.info("WebSocket CONNECT successful for socket: #{inspect(socket.id)}")
  end

  @doc """
  Logs a failed WebSocket connection.
  """
  def log_connect_failure(reason) do
    Logger.error("WebSocket CONNECT failed with reason: #{inspect(reason)}")
  end

  @doc """
  Logs a channel join attempt.
  """
  def log_join_attempt(topic, params) do
    Logger.info("WebSocket JOIN attempt for topic: #{topic} with params: #{inspect(params, pretty: true)}")
  end

  @doc """
  Logs a successful channel join.
  """
  def log_join_success(topic, socket, response) do
    player_id = socket.assigns[:player_id]
    game_id = socket.assigns[:game_id]
    
    Logger.info("WebSocket JOIN successful for topic: #{topic}, player_id: #{player_id}, game_id: #{game_id}, response: #{inspect(response, limit: :infinity)}")
  end

  @doc """
  Logs a failed channel join.
  """
  def log_join_failure(topic, reason) do
    Logger.error("WebSocket JOIN failed for topic: #{topic} with reason: #{inspect(reason)}")
  end

  @doc """
  Logs an incoming WebSocket message.
  """
  def log_incoming_message(event, payload, socket) do
    player_id = socket.assigns[:player_id]
    game_id = socket.assigns[:game_id]
    
    Logger.info("WebSocket RECEIVED #{event} from player_id: #{player_id}, game_id: #{game_id}, payload: #{inspect(payload, pretty: true)}")
  end

  @doc """
  Logs an outgoing WebSocket message (push).
  """
  def log_outgoing_message(event, payload, socket) do
    player_id = socket.assigns[:player_id]
    game_id = socket.assigns[:game_id]
    
    Logger.info("WebSocket SENT #{event} to player_id: #{player_id}, game_id: #{game_id}, payload: #{inspect(payload, pretty: true)}")
  end

  @doc """
  Logs a broadcast WebSocket message.
  """
  def log_broadcast_message(topic, event, payload) do
    Logger.info("WebSocket BROADCAST #{event} to topic: #{topic}, payload: #{inspect(payload, pretty: true)}")
  end

  @doc """
  Logs a channel termination.
  """
  def log_terminate(reason, socket) do
    player_id = socket.assigns[:player_id]
    game_id = socket.assigns[:game_id]
    
    Logger.info("WebSocket TERMINATE for player_id: #{player_id}, game_id: #{game_id}, reason: #{inspect(reason)}")
  end
end
