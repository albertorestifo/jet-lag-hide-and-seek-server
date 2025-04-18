defmodule JetLagServerWeb.API.GeocodingControllerTest do
  use JetLagServerWeb.ConnCase

  import Mock

  describe "autocomplete" do
    test "returns locations matching the query", %{conn: conn} do
      # Parse the real fixture to get locations
      fixture_json = File.read!("test/fixtures/photon_madrid_response.json") |> Jason.decode!()
      features = Map.get(fixture_json, "features", [])

      # Create Location structs from the fixture
      mock_locations =
        Enum.map(features, fn feature ->
          JetLagServer.Geocoding.Structs.Location.from_photon_feature(feature)
        end)

      with_mock JetLagServer.Geocoding.Photon,
        search: fn _query, opts ->
          # Verify that the layers option is being passed
          assert Keyword.get(opts, :layers) == ["country", "state", "city"]
          {:ok, mock_locations}
        end do
        conn = get(conn, ~p"/api/geocoding/autocomplete?query=Madrid")
        assert %{"data" => data} = json_response(conn, 200)
        assert length(data) == length(mock_locations)
        assert hd(data)["title"] == "Madrid"

        # Check that all locations have the expected fields
        Enum.each(data, fn location ->
          assert Map.has_key?(location, "id")
          assert Map.has_key?(location, "title")
          assert Map.has_key?(location, "subtitle")
          assert Map.has_key?(location, "coordinates")
        end)
      end
    end

    test "returns error when search fails", %{conn: conn} do
      with_mock JetLagServer.Geocoding.Photon,
        search: fn _query, opts ->
          # Verify that the layers option is being passed
          assert Keyword.get(opts, :layers) == ["country", "state", "city"]
          {:error, "API error"}
        end do
        conn = get(conn, ~p"/api/geocoding/autocomplete?query=Madrid")
        assert %{"error" => %{"code" => "search_failed"}} = json_response(conn, 500)
      end
    end
  end

  describe "boundaries" do
    test "returns boundaries for a valid location ID", %{conn: conn} do
      # Parse the real fixture to get boundaries
      fixture_json = File.read!("test/fixtures/osm_madrid_response.json") |> Jason.decode!()

      # Create a Boundary struct from the fixture
      mock_boundaries =
        JetLagServer.Geocoding.Structs.Boundary.from_osm_response(
          fixture_json,
          "R",
          "5326784"
        )

      with_mock JetLagServer.Geocoding,
        get_location_boundaries: fn _type, _id -> {:ok, mock_boundaries} end do
        conn = get(conn, ~p"/api/geocoding/boundaries/way:123456")
        assert %{"data" => data} = json_response(conn, 200)
        assert data["name"] == "Madrid"

        # Check that the response has all the expected fields
        assert Map.has_key?(data, "name")
        assert Map.has_key?(data, "type")
        assert Map.has_key?(data, "osm_id")
        assert Map.has_key?(data, "osm_type")
        # bounding_box is no longer included in the API response
        refute Map.has_key?(data, "bounding_box")
        assert Map.has_key?(data, "coordinates")
        assert Map.has_key?(data, "boundaries")

        # Check that the boundaries data is a GeoJSON object
        assert Map.has_key?(data["boundaries"], "type")
        assert Map.has_key?(data["boundaries"], "coordinates")
      end
    end

    test "returns error for invalid location ID format", %{conn: conn} do
      conn = get(conn, ~p"/api/geocoding/boundaries/invalid")
      assert %{"error" => %{"code" => "invalid_id"}} = json_response(conn, 400)
    end

    test "returns error when boundaries fetch fails", %{conn: conn} do
      with_mock JetLagServer.Geocoding,
        get_location_boundaries: fn _type, _id -> {:error, "API error"} end do
        conn = get(conn, ~p"/api/geocoding/boundaries/way:123456")
        assert %{"error" => %{"code" => "boundaries_fetch_failed"}} = json_response(conn, 500)
      end
    end
  end
end
