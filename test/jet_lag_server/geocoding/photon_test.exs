defmodule JetLagServer.Geocoding.PhotonTest do
  use JetLagServer.DataCase
  import Mock

  alias JetLagServer.Geocoding.Photon
  alias JetLagServer.Geocoding.Structs.Location

  describe "search/2" do
    test "builds URL with default layers" do
      expected_url =
        "https://photon.komoot.io/api?q=Madrid&limit=10&lang=en&layer=country&layer=state&layer=city"

      with_mock HTTPoison,
        get: fn url ->
          assert url == expected_url

          {:ok,
           %HTTPoison.Response{
             status_code: 200,
             body: File.read!("test/fixtures/photon_madrid_response.json")
           }}
        end do
        {:ok, locations} = Photon.search("Madrid")

        assert length(locations) == 5

        # Check the first location
        first_location = Enum.at(locations, 0)
        assert %Location{} = first_location
        assert first_location.title == "Madrid"
        assert first_location.subtitle == "City"
        assert first_location.osm_id == "5326784"
        assert first_location.osm_type == "R"
        assert first_location.type == "city"
        assert first_location.coordinates == [-3.7035825, 40.4167047]

        # Check the second location
        second_location = Enum.at(locations, 1)
        assert %Location{} = second_location
        assert second_location.title == "Comunidad de Madrid"
        assert second_location.subtitle == "State"
        assert second_location.osm_id == "349055"
        assert second_location.osm_type == "R"
        assert second_location.type == "state"
      end
    end

    test "builds URL with custom layers" do
      expected_url =
        "https://photon.komoot.io/api?q=Madrid&limit=5&lang=fr&layer=country&layer=city"

      with_mock HTTPoison,
        get: fn url ->
          assert url == expected_url

          {:ok,
           %HTTPoison.Response{
             status_code: 200,
             body: File.read!("test/fixtures/photon_madrid_response.json")
           }}
        end do
        Photon.search("Madrid", limit: 5, lang: "fr", layers: ["country", "city"])
      end
    end

    test "builds URL with custom limit and lang" do
      expected_url =
        "https://photon.komoot.io/api?q=Madrid&limit=20&lang=es&layer=country&layer=state&layer=city"

      with_mock HTTPoison,
        get: fn url ->
          assert url == expected_url

          {:ok,
           %HTTPoison.Response{
             status_code: 200,
             body: File.read!("test/fixtures/photon_madrid_response.json")
           }}
        end do
        Photon.search("Madrid", limit: 20, lang: "es")
      end
    end

    test "handles empty layers list" do
      expected_url = "https://photon.komoot.io/api?q=Madrid&limit=10&lang=en"

      with_mock HTTPoison,
        get: fn url ->
          assert url == expected_url

          {:ok,
           %HTTPoison.Response{
             status_code: 200,
             body: File.read!("test/fixtures/photon_madrid_response.json")
           }}
        end do
        Photon.search("Madrid", layers: [])
      end
    end

    test "properly encodes query parameters" do
      expected_url =
        "https://photon.komoot.io/api?q=New%20York&limit=10&lang=en&layer=country&layer=state&layer=city"

      with_mock HTTPoison,
        get: fn url ->
          assert url == expected_url
          {:ok, %HTTPoison.Response{status_code: 200, body: "{\"features\":[]}"}}
        end do
        Photon.search("New York")
      end
    end

    test "returns error on HTTP error" do
      with_mock HTTPoison,
        get: fn _url ->
          {:error, %HTTPoison.Error{reason: "timeout"}}
        end do
        assert {:error, "Error calling Photon API: timeout"} = Photon.search("Madrid")
      end
    end

    test "returns error on non-200 status code" do
      with_mock HTTPoison,
        get: fn _url ->
          {:ok, %HTTPoison.Response{status_code: 404, body: ""}}
        end do
        assert {:error, "Photon API returned status code 404"} = Photon.search("Madrid")
      end
    end

    test "parses response into Location structs" do
      response_body = """
      {
        "features": [
          {
            "properties": {
              "osm_id": 123456,
              "osm_type": "way",
              "osm_value": "city",
              "name": "Madrid",
              "country": "Spain"
            },
            "geometry": {
              "coordinates": [-3.7038, 40.4168]
            }
          }
        ]
      }
      """

      with_mock HTTPoison,
        get: fn _url ->
          {:ok, %HTTPoison.Response{status_code: 200, body: response_body}}
        end do
        {:ok, locations} = Photon.search("Madrid")

        assert length(locations) == 1
        location = hd(locations)

        assert %Location{} = location
        assert location.title == "Madrid"
        assert location.subtitle == "City"
        assert location.osm_id == "123456"
        assert location.osm_type == "way"
        assert location.type == "city"
        assert location.coordinates == [-3.7038, 40.4168]
      end
    end

    test "parses real response into Location structs" do
      with_mock HTTPoison,
        get: fn _url ->
          {:ok,
           %HTTPoison.Response{
             status_code: 200,
             body: File.read!("test/fixtures/photon_madrid_response.json")
           }}
        end do
        {:ok, locations} = Photon.search("Madrid")

        assert length(locations) == 5

        # Check all locations are parsed correctly
        Enum.each(locations, fn location ->
          assert %Location{} = location
          assert is_binary(location.title)
          assert is_binary(location.subtitle)
          assert is_binary(location.osm_id), "osm_id should be a string"
          assert is_binary(location.osm_type), "osm_type should be a string"
          assert is_binary(location.type), "type should be a string"
          assert is_list(location.coordinates)
          assert length(location.coordinates) == 2
        end)
      end
    end
  end
end
