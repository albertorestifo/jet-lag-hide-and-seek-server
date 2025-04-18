defmodule JetLagServer.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `JetLagServer.Games` context.
  """

  @doc """
  Generate a valid location.
  """
  def location_fixture(attrs \\ %{}) do
    # Generate a unique osm_id if not provided
    attrs =
      if Map.has_key?(attrs, :osm_id) || Map.has_key?(attrs, "osm_id") do
        attrs
      else
        random_id = :rand.uniform(999_999_999) |> to_string()
        Map.put(attrs, :osm_id, random_id)
      end

    {:ok, location} =
      attrs
      |> Enum.into(%{
        name: "Madrid",
        type: "City",
        coordinates: [-3.7038, 40.4168],
        bounding_box: [-3.8, 40.3, -3.6, 40.5],
        osm_type: "way"
      })
      |> JetLagServer.Games.create_location()

    location
  end

  @doc """
  Generate valid game settings.
  """
  def game_settings_fixture(attrs \\ %{}) do
    {:ok, settings} =
      attrs
      |> Enum.into(%{
        units: "iso",
        hiding_zones: ["bus_stops", "local_trains"],
        hiding_zone_size: 500,
        game_duration: 1,
        day_start_time: "09:00",
        day_end_time: "18:00"
      })
      |> JetLagServer.Games.create_game_settings()

    settings
  end

  @doc """
  Generate a game with a location, settings, and a creator player.
  """
  def game_fixture(attrs \\ %{}) do
    # Create a location first if not provided
    location = Map.get(attrs, :location) || location_fixture()

    # Create a game with default values
    {:ok, game} =
      JetLagServer.Games.create_game(%{
        location_id: Map.get(attrs, :location_id, "#{location.osm_type}:#{location.osm_id}"),
        settings:
          Map.get(attrs, :settings, %{
            units: "iso",
            hiding_zones: ["bus_stops", "local_trains"],
            hiding_zone_size: 500,
            game_duration: 1,
            day_start_time: "09:00",
            day_end_time: "18:00"
          }),
        creator:
          Map.get(attrs, :creator, %{
            name: "John Doe"
          })
      })

    game
  end

  @doc """
  Generate a player for a game.
  """
  def player_fixture(game_id, attrs \\ %{}) do
    {:ok, player} =
      attrs
      |> Enum.into(%{
        name: "Jane Smith",
        game_id: game_id
      })
      |> JetLagServer.Games.create_player()

    player
  end
end
