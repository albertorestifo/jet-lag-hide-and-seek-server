defmodule JetLagServer.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `JetLagServer.Games` context.
  """

  @doc """
  Generate a valid location.
  """
  def location_fixture(attrs \\ %{}) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        name: "Madrid",
        type: "City",
        coordinates: [-3.7038, 40.4168],
        bounding_box: [-3.8, 40.3, -3.6, 40.5],
        osm_id: "12345678",
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
    # Create a game with default values
    {:ok, game} =
      JetLagServer.Games.create_game(%{
        location: Map.get(attrs, :location, %{
          name: "Madrid",
          type: "City",
          coordinates: [-3.7038, 40.4168],
          bounding_box: [-3.8, 40.3, -3.6, 40.5],
          osm_id: "12345678",
          osm_type: "way"
        }),
        settings: Map.get(attrs, :settings, %{
          units: "iso",
          hiding_zones: ["bus_stops", "local_trains"],
          hiding_zone_size: 500,
          game_duration: 1,
          day_start_time: "09:00",
          day_end_time: "18:00"
        }),
        creator: Map.get(attrs, :creator, %{
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
