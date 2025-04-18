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

### game_state

Sent when a client connects or reconnects to the WebSocket. Contains the full game state.

```json
{
  "type": "game_state",
  "data": {
    "game": {
      "id": "game-123",
      "code": "ABC123",
      "status": "waiting",
      "created_at": "2023-06-15T14:30:00Z",
      "started_at": null,
      "location": {
        "name": "Madrid",
        "type": "City",
        "coordinates": [-3.7038, 40.4168],
        "osm_id": "12345678",
        "osm_type": "way"
      },
      "settings": {
        "units": "iso",
        "hiding_zones": ["bus_stops", "local_trains"],
        "hiding_zone_size": 500,
        "game_duration": 1,
        "day_start_time": "09:00",
        "day_end_time": "18:00"
      },
      "players": [
        {
          "id": "player-123",
          "name": "John Doe",
          "is_creator": true
        },
        {
          "id": "player-456",
          "name": "Jane Smith",
          "is_creator": false
        }
      ]
    }
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
2. Server sends current game state in the join response
3. Server also sends a `game_state` event with the full game state
4. Server broadcasts events as they occur
5. Client sends messages to perform actions
6. Connection is closed when the game ends or the client disconnects

## Reconnection

If the client application restarts or loses connection, it should reconnect to the WebSocket using the same token. Upon reconnection, the server will:

1. Send the current game state in the join response
2. Send a `game_state` event with the full game state

This allows the client to restore its state and continue participating in the game without disruption.

## Error Handling

If the server encounters an error processing a message, it will respond with an `error` message. Clients should handle these errors appropriately.

## Reconnection

If the connection is lost, clients should attempt to reconnect with exponential backoff. The server will send the current game state upon reconnection.
