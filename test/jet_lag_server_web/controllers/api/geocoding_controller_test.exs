defmodule JetLagServerWeb.API.GeocodingControllerTest do
  use JetLagServerWeb.ConnCase

  import Mock

  describe "autocomplete" do
    test "returns locations matching the query", %{conn: conn} do
      mock_locations = [
        %JetLagServer.Geocoding.Structs.Location{
          id: "way:123456",
          title: "Madrid",
          subtitle: "City",
          coordinates: [-3.7038, 40.4168],
          osm_id: "123456",
          osm_type: "way",
          type: "city"
        }
      ]

      with_mock JetLagServer.Geocoding.Photon,
        search: fn _query, _opts -> {:ok, mock_locations} end do
        conn = get(conn, ~p"/api/geocoding/autocomplete?query=Madrid")
        assert %{"data" => data} = json_response(conn, 200)
        assert length(data) == 1
        assert hd(data)["title"] == "Madrid"
      end
    end

    test "returns error when search fails", %{conn: conn} do
      with_mock JetLagServer.Geocoding.Photon,
        search: fn _query, _opts -> {:error, "API error"} end do
        conn = get(conn, ~p"/api/geocoding/autocomplete?query=Madrid")
        assert %{"error" => %{"code" => "search_failed"}} = json_response(conn, 500)
      end
    end
  end

  describe "boundaries" do
    test "returns boundaries for a valid location ID", %{conn: conn} do
      mock_boundaries = %JetLagServer.Geocoding.Structs.Boundary{
        name: "Madrid",
        type: "city",
        osm_id: "123456",
        osm_type: "way",
        bounding_box: [-3.8, 40.3, -3.6, 40.5],
        coordinates: [-3.7038, 40.4168],
        boundaries: %{type: "Polygon", coordinates: []}
      }

      with_mock JetLagServer.Geocoding,
        get_location_boundaries: fn _type, _id -> {:ok, mock_boundaries} end do
        conn = get(conn, ~p"/api/geocoding/boundaries/way:123456")
        assert %{"data" => data} = json_response(conn, 200)
        assert data["name"] == "Madrid"
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
