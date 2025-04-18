# JetLag Hide & Seek WebSocket Protocol

This document describes the WebSocket protocol used for real-time communication in the JetLag Hide & Seek game.

## Connection

WebSocket connections are established at the following endpoint:

```
wss://api.jetlag.example.com/ws/games/{gameId}
```

Note: The WebSocket path is `/ws` and not `/socket` as is common in Phoenix applications.

Where `{gameId}` is the unique identifier for the game.

## Authentication

When connecting to the WebSocket, clients should include a token in the query parameters:

```
wss://api.jetlag.example.com/ws/games/{gameId}?token={token}
```

The token is provided in the response when creating or joining a game.

## Message Format

All messages are JSON objects with the following structure:

```json
{
  "type": "message_type",
  "data": {
    // Message-specific data
  }
}
```

## Server-to-Client Messages

### player_joined

Sent when a new player joins the game.

```json
{
  "type": "player_joined",
  "data": {
    "player": {
      "id": "player-456",
      "name": "Jane Smith",
      "is_creator": false
    }
  }
}
```

### player_left

Sent when a player leaves the game.

```json
{
  "type": "player_left",
  "data": {
    "player_id": "player-456"
  }
}
```

### game_started

Sent when the game is started by the creator.

```json
{
  "type": "game_started",
  "data": {
    "started_at": "2023-06-15T15:00:00Z"
  }
}
```

### game_updated

Sent when game settings are updated.

```json
{
  "type": "game_updated",
  "data": {
    "game": {
      // Full game object
    }
  }
}
```

### error

Sent when an error occurs.

```json
{
  "type": "error",
  "data": {
    "code": "invalid_operation",
    "message": "Cannot perform this action"
  }
}
```

## Client-to-Server Messages

### join_game

Sent by a client to join a game (alternative to the REST API endpoint).

```json
{
  "type": "join_game",
  "data": {
    "playerName": "Jane Smith"
  }
}
```

### leave_game

Sent by a client to leave a game.

```json
{
  "type": "leave_game",
  "data": {}
}
```

### start_game

Sent by the game creator to start the game.

```json
{
  "type": "start_game",
  "data": {}
}
```

### ping

Sent by clients to keep the connection alive.

```json
{
  "type": "ping",
  "data": {}
}
```

The server will respond with a `pong` message:

```json
{
  "type": "pong",
  "data": {}
}
```

Note: In the actual implementation, the server uses Elixir structs for all events, which are automatically encoded to JSON when sent over the WebSocket.

## Connection Lifecycle

1. Client establishes WebSocket connection
2. Server sends current game state
3. Server broadcasts events as they occur
4. Client sends messages to perform actions
5. Connection is closed when the game ends or the client disconnects

## Error Handling

If the server encounters an error processing a message, it will respond with an `error` message. Clients should handle these errors appropriately.

## Reconnection

If the connection is lost, clients should attempt to reconnect with exponential backoff. The server will send the current game state upon reconnection.
