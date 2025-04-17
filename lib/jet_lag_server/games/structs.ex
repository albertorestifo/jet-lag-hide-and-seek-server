defmodule JetLagServer.Games.Structs do
  @moduledoc """
  This module defines the structs used in the JetLag Hide & Seek game.
  """

  defmodule Location do
    @moduledoc """
    Struct representing a location in the game.
    """
    @derive {Jason.Encoder, except: []}
    defstruct [
      :name,
      :type,
      :coordinates,
      :bounding_box,
      :osm_id,
      :osm_type
    ]

    @doc """
    Converts a Location schema to a Location struct.
    """
    def from_schema(%JetLagServer.Games.Location{} = location) do
      %__MODULE__{
        name: location.name,
        type: location.type,
        coordinates: location.coordinates,
        bounding_box: location.bounding_box,
        osm_id: location.osm_id,
        osm_type: location.osm_type
      }
    end
  end

  defmodule GameSettings do
    @moduledoc """
    Struct representing game settings.
    """
    @derive {Jason.Encoder, except: []}
    defstruct [
      :units,
      :hiding_zones,
      :hiding_zone_size,
      :game_duration,
      :day_start_time,
      :day_end_time
    ]

    @doc """
    Converts a GameSettings schema to a GameSettings struct.
    """
    def from_schema(%JetLagServer.Games.GameSettings{} = settings) do
      %__MODULE__{
        units: settings.units,
        hiding_zones: settings.hiding_zones,
        hiding_zone_size: settings.hiding_zone_size,
        game_duration: settings.game_duration,
        day_start_time: settings.day_start_time,
        day_end_time: settings.day_end_time
      }
    end
  end

  defmodule Player do
    @moduledoc """
    Struct representing a player in the game.
    """
    @derive {Jason.Encoder, except: []}
    defstruct [
      :id,
      :name,
      :is_creator
    ]

    @doc """
    Converts a Player schema to a Player struct.
    """
    def from_schema(%JetLagServer.Games.Player{} = player) do
      %__MODULE__{
        id: player.id,
        name: player.name,
        is_creator: player.is_creator
      }
    end
  end

  defmodule Game do
    @moduledoc """
    Struct representing a game.
    """
    @derive {Jason.Encoder, except: []}
    defstruct [
      :id,
      :code,
      :location,
      :settings,
      :players,
      :status,
      :created_at,
      :started_at
    ]

    @doc """
    Converts a Game schema to a Game struct.
    """
    def from_schema(%JetLagServer.Games.Game{} = game) do
      %__MODULE__{
        id: game.id,
        code: game.code,
        location: Location.from_schema(game.location),
        settings: GameSettings.from_schema(game.settings),
        players: Enum.map(game.players, &Player.from_schema/1),
        status: game.status,
        created_at: game.inserted_at,
        started_at: game.started_at
      }
    end
  end

  defmodule CreateGameResponse do
    @moduledoc """
    Struct representing the response when creating a game.
    """
    @derive {Jason.Encoder, except: []}
    defstruct [
      :game_id,
      :game_code,
      :websocket_url
    ]
  end

  defmodule JoinGameResponse do
    @moduledoc """
    Struct representing the response when joining a game.
    """
    @derive {Jason.Encoder, except: []}
    defstruct [
      :game_id,
      :player_id,
      :websocket_url,
      :game
    ]
  end

  defmodule PlayerJoinedEvent do
    @moduledoc """
    Struct representing a player joined event.
    """
    @derive {Jason.Encoder, except: []}
    defstruct [
      :player
    ]
  end

  defmodule PlayerLeftEvent do
    @moduledoc """
    Struct representing a player left event.
    """
    @derive {Jason.Encoder, except: []}
    defstruct [
      :player_id
    ]
  end

  defmodule GameStartedEvent do
    @moduledoc """
    Struct representing a game started event.
    """
    @derive {Jason.Encoder, except: []}
    defstruct [
      :started_at
    ]
  end

  defmodule GameUpdatedEvent do
    @moduledoc """
    Struct representing a game updated event.
    """
    @derive {Jason.Encoder, except: []}
    defstruct [
      :game
    ]
  end

  defmodule ErrorEvent do
    @moduledoc """
    Struct representing an error event.
    """
    @derive {Jason.Encoder, except: []}
    defstruct [
      :code,
      :message
    ]
  end

  defmodule PingEvent do
    @moduledoc """
    Struct representing a ping event.
    """
    @derive {Jason.Encoder, except: []}
    defstruct []
  end

  defmodule PongEvent do
    @moduledoc """
    Struct representing a pong event.
    """
    @derive {Jason.Encoder, except: []}
    defstruct []
  end
end
