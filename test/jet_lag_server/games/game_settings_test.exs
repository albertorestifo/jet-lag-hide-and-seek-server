defmodule JetLagServer.Games.GameSettingsTest do
  use JetLagServer.DataCase

  alias JetLagServer.Games.GameSettings

  describe "game_settings schema" do
    test "changeset with valid attributes" do
      valid_attrs = %{
        units: "iso",
        hiding_zones: ["bus_stops", "local_trains"],
        hiding_zone_size: 500,
        game_duration: 1,
        day_start_time: "09:00",
        day_end_time: "18:00"
      }

      changeset = GameSettings.changeset(%GameSettings{}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid units" do
      invalid_attrs = %{
        units: "invalid_units",
        hiding_zones: ["bus_stops", "local_trains"],
        hiding_zone_size: 500,
        game_duration: 1,
        day_start_time: "09:00",
        day_end_time: "18:00"
      }

      changeset = GameSettings.changeset(%GameSettings{}, invalid_attrs)
      assert %{units: ["is invalid"]} = errors_on(changeset)
    end

    test "changeset with invalid hiding_zones" do
      invalid_attrs = %{
        units: "iso",
        hiding_zones: ["invalid_zone", "local_trains"],
        hiding_zone_size: 500,
        game_duration: 1,
        day_start_time: "09:00",
        day_end_time: "18:00"
      }

      changeset = GameSettings.changeset(%GameSettings{}, invalid_attrs)
      assert %{hiding_zones: ["has an invalid entry"]} = errors_on(changeset)
    end

    test "changeset with invalid hiding_zone_size" do
      invalid_attrs = %{
        units: "iso",
        hiding_zones: ["bus_stops", "local_trains"],
        # Too small
        hiding_zone_size: 50,
        game_duration: 1,
        day_start_time: "09:00",
        day_end_time: "18:00"
      }

      changeset = GameSettings.changeset(%GameSettings{}, invalid_attrs)
      assert %{hiding_zone_size: ["must be greater than or equal to 100"]} = errors_on(changeset)
    end

    test "changeset with invalid game_duration" do
      invalid_attrs = %{
        units: "iso",
        hiding_zones: ["bus_stops", "local_trains"],
        hiding_zone_size: 500,
        # Must be at least 1
        game_duration: 0,
        day_start_time: "09:00",
        day_end_time: "18:00"
      }

      changeset = GameSettings.changeset(%GameSettings{}, invalid_attrs)
      assert %{game_duration: ["must be greater than or equal to 1"]} = errors_on(changeset)
    end

    test "changeset with invalid day_start_time format" do
      invalid_attrs = %{
        units: "iso",
        hiding_zones: ["bus_stops", "local_trains"],
        hiding_zone_size: 500,
        game_duration: 1,
        # Missing leading zeros
        day_start_time: "9:0",
        day_end_time: "18:00"
      }

      changeset = GameSettings.changeset(%GameSettings{}, invalid_attrs)
      assert %{day_start_time: ["has invalid format"]} = errors_on(changeset)
    end

    test "changeset with invalid day_end_time format" do
      invalid_attrs = %{
        units: "iso",
        hiding_zones: ["bus_stops", "local_trains"],
        hiding_zone_size: 500,
        game_duration: 1,
        day_start_time: "09:00",
        # Invalid hour
        day_end_time: "24:00"
      }

      changeset = GameSettings.changeset(%GameSettings{}, invalid_attrs)
      assert %{day_end_time: ["has invalid format"]} = errors_on(changeset)
    end
  end
end
