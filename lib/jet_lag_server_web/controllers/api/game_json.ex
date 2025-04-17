defmodule JetLagServerWeb.API.GameJSON do
  alias JetLagServer.Games.{Game, Player, Location, GameSettings}

  @doc """
  Renders a list of games.
  """
  def index(%{games: games}) do
    %{data: for(game <- games, do: data(game))}
  end

  @doc """
  Renders a single game.
  """
  def show(%{game: game}) do
    %{data: data(game)}
  end
  
  @doc """
  Renders a newly created game.
  """
  def created(%{game: game, token: token}) do
    %{
      gameId: game.id,
      gameCode: game.code,
      websocketUrl: "wss://#{JetLagServerWeb.Endpoint.host()}/ws/games/#{game.id}?token=#{token}"
    }
  end
  
  @doc """
  Renders a response for joining a game.
  """
  def joined(%{game: game, player: player, token: token}) do
    %{
      gameId: game.id,
      playerId: player.id,
      websocketUrl: "wss://#{JetLagServerWeb.Endpoint.host()}/ws/games/#{game.id}?token=#{token}",
      game: data(game)
    }
  end

  @doc """
  Renders game data.
  """
  def data(%Game{} = game) do
    %{
      id: game.id,
      code: game.code,
      location: location_data(game.location),
      settings: settings_data(game.settings),
      players: Enum.map(game.players, &player_data/1),
      status: game.status,
      createdAt: game.inserted_at,
      startedAt: game.started_at
    }
  end
  
  defp location_data(%Location{} = location) do
    %{
      name: location.name,
      type: location.type,
      coordinates: location.coordinates,
      boundingBox: location.bounding_box,
      osmId: location.osm_id,
      osmType: location.osm_type
    }
  end
  
  defp settings_data(%GameSettings{} = settings) do
    %{
      units: settings.units,
      hidingZones: settings.hiding_zones,
      hidingZoneSize: settings.hiding_zone_size,
      gameDuration: settings.game_duration,
      dayStartTime: settings.day_start_time,
      dayEndTime: settings.day_end_time
    }
  end
  
  defp player_data(%Player{} = player) do
    %{
      id: player.id,
      name: player.name,
      isCreator: player.is_creator
    }
  end
end
