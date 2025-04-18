defmodule JetLagServer.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias JetLagServer.Repo

  alias JetLagServer.Games.{Game, Player, Location, GameSettings}

  @doc """
  Returns the list of games.
  """
  def list_games do
    Repo.all(Game)
    |> Repo.preload([:location, :settings, :players])
  end

  @doc """
  Gets a single game.
  """
  def get_game(id) do
    Repo.get(Game, id)
    |> Repo.preload([:location, :settings, :players])
  end

  @doc """
  Gets a single game by code.
  """
  def get_game_by_code(code) do
    Repo.get_by(Game, code: code)
    |> Repo.preload([:location, :settings, :players])
  end

  @doc """
  Creates a game.
  """
  def create_game(attrs \\ %{}) do
    # Generate a unique game code
    code = generate_unique_code()

    # Get location data, handling both string and atom keys
    location_data = Map.get(attrs, :location, Map.get(attrs, "location"))

    # Create the location
    case create_location(location_data) do
      {:ok, location} ->
        # Get settings data, handling both string and atom keys
        settings_data = Map.get(attrs, :settings, Map.get(attrs, "settings"))

        # Create the game settings
        case create_game_settings(settings_data) do
          {:ok, settings} ->
            # Get creator data, handling both string and atom keys
            creator_data = Map.get(attrs, :creator, Map.get(attrs, "creator"))
            creator_name = Map.get(creator_data, :name, Map.get(creator_data, "name"))

            # Create the game
            {:ok, game} =
              %Game{}
              |> Game.changeset(%{
                code: code,
                location_id: location.id,
                settings_id: settings.id
              })
              |> Repo.insert()

            # Create the creator player
            {:ok, _player} =
              create_player(%{
                name: creator_name,
                is_creator: true,
                game_id: game.id
              })

            # Return the game with all associations loaded
            {:ok, get_game(game.id)}

          error ->
            error
        end

      error ->
        error
    end
  end

  @doc """
  Updates a game.
  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Starts a game and broadcasts a game_started event.
  """
  def start_game(%Game{} = game) do
    started_at = DateTime.utc_now() |> DateTime.truncate(:second)

    result =
      game
      |> Game.changeset(%{
        status: "active",
        started_at: started_at
      })
      |> Repo.update()

    case result do
      {:ok, updated_game} ->
        # Broadcast game started event
        JetLagServer.Games.EventBroadcaster.broadcast_game_started(
          updated_game.id,
          updated_game.started_at
        )

        {:ok, updated_game}

      error ->
        error
    end
  end

  @doc """
  Deletes a game.
  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Creates a location.
  """
  def create_location(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates game settings.
  """
  def create_game_settings(attrs \\ %{}) do
    %GameSettings{}
    |> GameSettings.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a player.
  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a player.
  """
  def get_player(id) do
    Repo.get(Player, id)
  end

  @doc """
  Adds a player to a game and broadcasts a player_joined event.
  """
  def add_player_to_game(game_id, player_name) do
    # Create the player
    {:ok, player} =
      create_player(%{
        name: player_name,
        game_id: game_id
      })

    # Broadcast player joined event
    player_struct = JetLagServer.Games.Structs.Player.from_schema(player)
    JetLagServer.Games.EventBroadcaster.broadcast_player_joined(game_id, player_struct)

    # Return the player
    {:ok, player}
  end

  @doc """
  Removes a player from a game and broadcasts a player_left event.
  """
  def remove_player_from_game(player_id) do
    player = get_player(player_id)
    game_id = player.game_id

    result = Repo.delete(player)

    # Broadcast player left event
    JetLagServer.Games.EventBroadcaster.broadcast_player_left(game_id, player_id)

    result
  end

  # Generates a unique game code
  defp generate_unique_code do
    code = Game.generate_code()

    case Repo.get_by(Game, code: code) do
      nil -> code
      _ -> generate_unique_code()
    end
  end

  @doc """
  Generates a token for WebSocket authentication.
  """
  def generate_token(game_id, player_id) do
    Phoenix.Token.sign(JetLagServerWeb.Endpoint, "game socket", %{
      game_id: game_id,
      player_id: player_id
    })
  end

  @doc """
  Verifies a token for WebSocket authentication.
  """
  def verify_token(token, game_id) do
    case Phoenix.Token.verify(JetLagServerWeb.Endpoint, "game socket", token, max_age: 86400) do
      {:ok, %{game_id: ^game_id, player_id: player_id}} ->
        {:ok, player_id}

      {:ok, _} ->
        {:error, :invalid_game}

      error ->
        error
    end
  end
end
