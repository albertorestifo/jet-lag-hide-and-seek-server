defmodule JetLagServer.Geocoding.Structs.LocationTest do
  use JetLagServer.DataCase

  alias JetLagServer.Geocoding.Structs.Location

  describe "from_photon_feature/1" do
    test "parses country correctly" do
      feature = %{
        "properties" => %{
          "osm_id" => 123456,
          "osm_type" => "relation",
          "osm_value" => "country",
          "name" => "Spain",
          "country" => "Spain"
        },
        "geometry" => %{
          "coordinates" => [-3.7492, 40.4637]
        }
      }

      location = Location.from_photon_feature(feature)
      
      assert location.id == "relation:123456"
      assert location.title == "Spain"
      assert location.subtitle == "Country"
      assert location.type == "country"
      assert location.coordinates == [-3.7492, 40.4637]
    end

    test "parses state correctly" do
      feature = %{
        "properties" => %{
          "osm_id" => 123456,
          "osm_type" => "relation",
          "osm_value" => "state",
          "name" => "California",
          "state" => "California",
          "country" => "United States"
        },
        "geometry" => %{
          "coordinates" => [-119.4179, 36.7783]
        }
      }

      location = Location.from_photon_feature(feature)
      
      assert location.id == "relation:123456"
      assert location.title == "California"
      assert location.subtitle == "State"
      assert location.type == "state"
      assert location.coordinates == [-119.4179, 36.7783]
    end

    test "parses city correctly" do
      feature = %{
        "properties" => %{
          "osm_id" => 123456,
          "osm_type" => "way",
          "osm_value" => "city",
          "name" => "Madrid",
          "city" => "Madrid",
          "state" => "Community of Madrid",
          "country" => "Spain"
        },
        "geometry" => %{
          "coordinates" => [-3.7038, 40.4168]
        }
      }

      location = Location.from_photon_feature(feature)
      
      assert location.id == "way:123456"
      assert location.title == "Madrid"
      assert location.subtitle == "City"
      assert location.type == "city"
      assert location.coordinates == [-3.7038, 40.4168]
    end

    test "parses town as city" do
      feature = %{
        "properties" => %{
          "osm_id" => 123456,
          "osm_type" => "way",
          "osm_value" => "town",
          "name" => "Alcalá de Henares",
          "country" => "Spain"
        },
        "geometry" => %{
          "coordinates" => [-3.3668, 40.4819]
        }
      }

      location = Location.from_photon_feature(feature)
      
      assert location.id == "way:123456"
      assert location.title == "Alcalá de Henares"
      assert location.subtitle == "City"
      assert location.type == "city"
      assert location.coordinates == [-3.3668, 40.4819]
    end

    test "parses place as city" do
      feature = %{
        "properties" => %{
          "osm_id" => 123456,
          "osm_type" => "way",
          "osm_key" => "place",
          "osm_value" => "village",
          "name" => "Small Village",
          "country" => "Spain"
        },
        "geometry" => %{
          "coordinates" => [-3.3668, 40.4819]
        }
      }

      location = Location.from_photon_feature(feature)
      
      assert location.id == "way:123456"
      assert location.title == "Small Village"
      assert location.subtitle == "City"
      assert location.type == "city"
      assert location.coordinates == [-3.3668, 40.4819]
    end

    test "handles missing geometry" do
      feature = %{
        "properties" => %{
          "osm_id" => 123456,
          "osm_type" => "way",
          "osm_value" => "city",
          "name" => "Madrid",
          "country" => "Spain"
        }
      }

      location = Location.from_photon_feature(feature)
      
      assert location.id == "way:123456"
      assert location.title == "Madrid"
      assert location.subtitle == "City"
      assert location.coordinates == [0, 0]
    end

    test "handles missing properties" do
      feature = %{
        "geometry" => %{
          "coordinates" => [-3.7038, 40.4168]
        }
      }

      location = Location.from_photon_feature(feature)
      
      assert location.id == "nil:nil"
      assert location.title == nil
      assert location.subtitle == "Other"
      assert location.coordinates == [-3.7038, 40.4168]
    end
  end
end
