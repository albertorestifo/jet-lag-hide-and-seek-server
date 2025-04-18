defmodule JetLagServer.Geocoding.OpenStreetMapTest do
  use JetLagServer.DataCase
  import Mock

  alias JetLagServer.Geocoding.OpenStreetMap
  alias JetLagServer.Geocoding.Structs.Boundary

  describe "get_boundaries/2" do
    test "fetches and parses boundaries correctly" do
      osm_type = "R"
      osm_id = "5326784"

      expected_url =
        "https://nominatim.openstreetmap.org/details.php?osmtype=R&osmid=5326784&class=boundary&format=json&polygon_geojson=1"

      with_mock HTTPoison,
        get: fn url, headers ->
          # Check URL
          assert url == expected_url

          # Check headers
          assert Enum.any?(headers, fn {key, value} ->
                   key == "User-Agent" && String.contains?(value, "JetLagHideAndSeekApp")
                 end)

          assert Enum.any?(headers, fn {key, value} ->
                   key == "Accept" && value == "application/json"
                 end)

          # Return real fixture data
          {:ok,
           %HTTPoison.Response{
             status_code: 200,
             body: File.read!("test/fixtures/osm_madrid_response.json")
           }}
        end do
        {:ok, boundary} = OpenStreetMap.get_boundaries(osm_type, osm_id)

        # Check that we got a proper Boundary struct
        assert %Boundary{} = boundary

        # Check basic properties
        assert boundary.name == "Madrid"
        assert boundary.osm_id == "5326784"
        assert boundary.osm_type == "R"

        # Check that we have boundaries data
        assert boundary.boundaries != nil

        # Note: bounding_box and coordinates might be nil depending on the API response
        # We're just checking that the struct is properly populated

        # If coordinates are present, check their format
        if boundary.coordinates do
          assert is_list(boundary.coordinates)
          assert length(boundary.coordinates) == 2
        end

        # If bounding_box is present, check its format
        if boundary.bounding_box do
          assert is_list(boundary.bounding_box)
          assert length(boundary.bounding_box) == 4
        end
      end
    end

    test "handles API error correctly" do
      with_mock HTTPoison,
        get: fn _url, _headers ->
          {:error, %HTTPoison.Error{reason: "timeout"}}
        end do
        assert {:error, "Error calling OpenStreetMap API: timeout"} =
                 OpenStreetMap.get_boundaries("R", "123")
      end
    end

    test "handles non-200 status code correctly" do
      with_mock HTTPoison,
        get: fn _url, _headers ->
          {:ok, %HTTPoison.Response{status_code: 404, body: ""}}
        end do
        assert {:error, "OpenStreetMap API returned status code 404"} =
                 OpenStreetMap.get_boundaries("R", "123")
      end
    end

    test "handles invalid JSON response correctly" do
      with_mock HTTPoison,
        get: fn _url, _headers ->
          {:ok, %HTTPoison.Response{status_code: 200, body: "not json"}}
        end do
        assert {:error, "Failed to parse OpenStreetMap API response"} =
                 OpenStreetMap.get_boundaries("R", "123")
      end
    end
  end
end
