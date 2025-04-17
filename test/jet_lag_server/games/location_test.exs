defmodule JetLagServer.Games.LocationTest do
  use JetLagServer.DataCase

  alias JetLagServer.Games.Location

  describe "location schema" do
    test "changeset with valid attributes" do
      valid_attrs = %{
        name: "Madrid",
        type: "City",
        coordinates: [-3.7038, 40.4168],
        bounding_box: [-3.8, 40.3, -3.6, 40.5],
        osm_id: "12345678",
        osm_type: "way"
      }

      changeset = Location.changeset(%Location{}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset with missing required fields" do
      invalid_attrs = %{
        type: "City",
        osm_id: "12345678",
        osm_type: "way"
      }

      changeset = Location.changeset(%Location{}, invalid_attrs)
      assert %{name: ["can't be blank"], coordinates: ["can't be blank"]} = errors_on(changeset)
    end

    test "changeset with invalid coordinates length" do
      invalid_attrs = %{
        name: "Madrid",
        type: "City",
        # Only one coordinate
        coordinates: [-3.7038],
        bounding_box: [-3.8, 40.3, -3.6, 40.5],
        osm_id: "12345678",
        osm_type: "way"
      }

      changeset = Location.changeset(%Location{}, invalid_attrs)

      assert %{coordinates: ["must contain exactly longitude and latitude"]} =
               errors_on(changeset)
    end

    test "changeset with invalid bounding_box length" do
      invalid_attrs = %{
        name: "Madrid",
        type: "City",
        coordinates: [-3.7038, 40.4168],
        # Missing one value
        bounding_box: [-3.8, 40.3, -3.6],
        osm_id: "12345678",
        osm_type: "way"
      }

      changeset = Location.changeset(%Location{}, invalid_attrs)

      assert %{bounding_box: ["must contain [minLon, minLat, maxLon, maxLat]"]} =
               errors_on(changeset)
    end
  end
end
