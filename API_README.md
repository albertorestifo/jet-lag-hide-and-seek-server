# JetLag Hide & Seek Game API

This document provides an overview of the JetLag Hide & Seek Game API and WebSocket protocol.

## API Endpoints

The API is available at the following base URL:

```
https://api.jetlag.example.com
```

### Create a Game

**Endpoint:** `POST /api/games`

Creates a new hide and seek game with the specified settings.

**Request Body:**

```json
{
  "location": {
    "name": "Madrid",
    "type": "City",
    "coordinates": [-3.7038, 40.4168],
    "boundingBox": [-3.8, 40.3, -3.6, 40.5],
    "osmId": "12345678",
    "osmType": "way"
  },
  "settings": {
    "units": "iso",
    "hidingZones": ["bus_stops", "local_trains"],
    "hidingZoneSize": 500,
    "gameDuration": 1,
    "dayStartTime": "09:00",
    "dayEndTime": "18:00"
  },
  "creator": {
    "name": "John Doe"
  }
}
```

**Response:**

```json
{
  "game_id": "game-123",
  "game_code": "ABC123",
  "websocket_url": "wss://api.jetlag.example.com/ws/games/game-123?token=xyz"
}
```

### Get Game Details

**Endpoint:** `GET /api/games/{gameId}`

Retrieves details about a specific game.

**Response:**

```json
{
  "data": {
    "id": "game-123",
    "code": "ABC123",
    "location": {
      "name": "Madrid",
      "type": "City",
      "coordinates": [-3.7038, 40.4168],
      "bounding_box": [-3.8, 40.3, -3.6, 40.5],
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
      }
    ],
    "status": "waiting",
    "created_at": "2023-06-15T14:30:00Z",
    "started_at": null
  }
}
```

### Start a Game

**Endpoint:** `POST /api/games/{gameId}/start`

Starts a game, preventing new players from joining.

**Response:**

```json
{
  "data": {
    "id": "game-123",
    "code": "ABC123",
    "location": {
      "name": "Madrid",
      "type": "City",
      "coordinates": [-3.7038, 40.4168],
      "boundingBox": [-3.8, 40.3, -3.6, 40.5],
      "osmId": "12345678",
      "osmType": "way"
    },
    "settings": {
      "units": "iso",
      "hidingZones": ["bus_stops", "local_trains"],
      "hidingZoneSize": 500,
      "gameDuration": 1,
      "dayStartTime": "09:00",
      "dayEndTime": "18:00"
    },
    "players": [
      {
        "id": "player-123",
        "name": "John Doe",
        "is_creator": true
      }
    ],
    "status": "active",
    "created_at": "2023-06-15T14:30:00Z",
    "started_at": "2023-06-15T15:00:00Z"
  }
}
```

### Join a Game

**Endpoint:** `POST /api/games/join`

Allows a player to join an existing game using a game code.

**Request Body:**

```json
{
  "game_code": "ABC123",
  "player_name": "Jane Smith"
}
```

**Response:**

```json
{
  "game_id": "game-123",
  "player_id": "player-456",
  "websocket_url": "wss://api.jetlag.example.com/ws/games/game-123?token=xyz",
  "game": {
    "id": "game-123",
    "code": "ABC123",
    "location": {
      "name": "Madrid",
      "type": "City",
      "coordinates": [-3.7038, 40.4168],
      "boundingBox": [-3.8, 40.3, -3.6, 40.5],
      "osmId": "12345678",
      "osmType": "way"
    },
    "settings": {
      "units": "iso",
      "hidingZones": ["bus_stops", "local_trains"],
      "hidingZoneSize": 500,
      "gameDuration": 1,
      "dayStartTime": "09:00",
      "dayEndTime": "18:00"
    },
    "players": [
      {
        "id": "player-123",
        "name": "John Doe",
        "isCreator": true
      },
      {
        "id": "player-456",
        "name": "Jane Smith",
        "isCreator": false
      }
    ],
    "status": "waiting",
    "createdAt": "2023-06-15T14:30:00Z",
    "startedAt": null
  }
}
```

## WebSocket Protocol

WebSocket connections are established at the following endpoint:

```
wss://api.jetlag.example.com/ws/games/{gameId}?token={token}
```

Where `{gameId}` is the unique identifier for the game and `{token}` is the authentication token provided in the response when creating or joining a game.

### Message Format

All messages are JSON objects with the following structure:

```json
{
  "type": "message_type",
  "data": {
    // Message-specific data
  }
}
```

### Server-to-Client Messages

- `player_joined`: Sent when a new player joins the game
- `player_left`: Sent when a player leaves the game
- `game_started`: Sent when the game is started by the creator
- `game_updated`: Sent when game settings are updated
- `error`: Sent when an error occurs

### Client-to-Server Messages

- `join_game`: Sent by a client to join a game (alternative to the REST API endpoint)
- `leave_game`: Sent by a client to leave a game
- `start_game`: Sent by the game creator to start the game
- `ping`: Sent by clients to keep the connection alive

For more detailed information about the WebSocket protocol, see the [WebSocket Protocol Documentation](priv/static/websocket_protocol.md).

## OpenAPI Specification

The complete OpenAPI specification for the API is available at:

```
/openapi.json
```

You can use this specification with tools like Swagger UI or Postman to explore and test the API.

## Running the Server

To start the Phoenix server:

1. Install dependencies with `mix deps.get`
2. Create and migrate your database with `mix ecto.setup`
3. Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
