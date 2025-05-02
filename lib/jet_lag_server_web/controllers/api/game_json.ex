defmodule JetLagServerWeb.API.GameJSON do
  alias JetLagServer.Games.Game
  alias JetLagServer.Games.Structs

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
    %Structs.CreateGameResponse{
      game_id: game.id,
      game_code: game.code,
      websocket_url:
        "wss://#{JetLagServerWeb.Endpoint.host()}/ws/games/#{game.id}?token=#{token}",
      token: token
    }
  end

  @doc """
  Renders a response for joining a game.
  """
  def joined(%{game: game, player: player, token: token}) do
    %Structs.JoinGameResponse{
      game_id: game.id,
      player_id: player.id,
      websocket_url:
        "wss://#{JetLagServerWeb.Endpoint.host()}/ws/games/#{game.id}?token=#{token}",
      game: Structs.Game.from_schema(game)
    }
  end

  @doc """
  Renders game data.
  """
  def data(%Game{} = game) do
    Structs.Game.from_schema(game)
  end
end
