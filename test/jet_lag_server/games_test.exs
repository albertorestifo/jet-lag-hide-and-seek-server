defmodule JetLagServer.GamesTest do
  use JetLagServer.DataCase

  alias JetLagServer.Games
  alias JetLagServer.Games.{Game, Player, GameSettings}
  import JetLagServer.GamesFixtures

  describe "games" do
    test "list_games/0 returns all games" do
      game = game_fixture()
      games = Games.list_games()
      assert Enum.find(games, fn g -> g.id == game.id end)
    end

    test "get_game/1 returns the game with given id" do
      game = game_fixture()
      assert %Game{id: id} = Games.get_game(game.id)
      assert id == game.id
    end

    test "get_game_by_code/1 returns the game with given code" do
      game = game_fixture()
      assert %Game{code: code} = Games.get_game_by_code(game.code)
      assert code == game.code
    end

    test "create_game/1 with valid location_id creates a game" do
      # Create a cached boundary first
      cached = cached_boundary_fixture()

      valid_attrs = %{
        location_id: "#{cached.osm_type}:#{cached.osm_id}",
        settings: %{
          units: :iso,
          game_size: :medium,
          hiding_zones: ["bus_stops", "local_trains"],
          game_duration: 1,
          day_start_time: "09:00",
          day_end_time: "18:00"
        },
        creator: %{
          name: "John Doe"
        }
      }

      assert {:ok, %Game{} = game} = Games.create_game(valid_attrs)
      assert game.code =~ ~r/^[A-Z0-9]{6}$/
      assert game.status == :waiting
      assert game.started_at == nil
      assert game.osm_type == cached.osm_type
      assert game.osm_id == cached.osm_id
      assert game.settings.units == :iso
      assert game.settings.game_size == :medium
      assert [player] = game.players
      assert player.name == "John Doe"
      assert player.is_creator == true
    end

    test "create_game/1 with non-existent location_id returns error" do
      invalid_attrs = %{
        # Non-existent location
        location_id: "way:999999",
        settings: %{
          units: :iso,
          game_size: :medium,
          hiding_zones: ["bus_stops", "local_trains"],
          game_duration: 1,
          day_start_time: "09:00",
          day_end_time: "18:00"
        },
        creator: %{
          name: "John Doe"
        }
      }

      assert {:error, :location_not_found} = Games.create_game(invalid_attrs)
    end

    test "create_game/1 with invalid location_id format returns error" do
      invalid_attrs = %{
        # Invalid format
        location_id: "invalid-format",
        settings: %{
          units: :iso,
          game_size: :medium,
          hiding_zones: ["bus_stops", "local_trains"],
          game_duration: 1,
          day_start_time: "09:00",
          day_end_time: "18:00"
        },
        creator: %{
          name: "John Doe"
        }
      }

      assert {:error, :invalid_location_id_format} = Games.create_game(invalid_attrs)
    end

    test "start_game/1 updates the game status and sets started_at" do
      game = game_fixture()
      assert game.status == :waiting
      assert game.started_at == nil

      assert {:ok, %Game{} = updated_game} = Games.start_game(game)
      assert updated_game.status == :active
      assert updated_game.started_at != nil
    end

    test "delete_game/2 deletes the game and all associated data when called by the creator" do
      game = game_fixture()
      creator = Enum.find(game.players, fn p -> p.is_creator end)

      # Add a non-creator player with location
      {:ok, player} = Games.add_player_to_game(game.id, "Non-Creator")

      # Add location for the player
      {:ok, _location} = Games.update_player_location(player.id, 40.4168, -3.7038, 10.0)

      # Get the settings ID to check later
      settings_id = game.settings_id

      # Delete the game
      assert {:ok, %Game{}} = Games.delete_game(game, creator.id)

      # Verify game is deleted
      assert nil == Games.get_game(game.id)

      # Verify players are deleted
      assert nil == Games.get_player(creator.id)
      assert nil == Games.get_player(player.id)

      # Verify player locations are deleted
      import Ecto.Query

      assert [] ==
               JetLagServer.Repo.all(
                 from pl in JetLagServer.Games.PlayerLocation, where: pl.player_id == ^player.id
               )

      # Verify game settings are deleted
      assert nil == JetLagServer.Repo.get(JetLagServer.Games.GameSettings, settings_id)
    end

    test "delete_game/2 returns error when called by non-creator" do
      game = game_fixture()

      # Add a non-creator player
      {:ok, player} = Games.add_player_to_game(game.id, "Non-Creator")

      assert {:error, :not_creator} = Games.delete_game(game, player.id)
      assert Games.get_game(game.id) != nil
    end
  end

  # We no longer need to test cached boundaries directly since we're using Geocoding module

  describe "game_settings" do
    test "create_game_settings/1 with valid data creates game settings" do
      valid_attrs = %{
        units: :iso,
        game_size: :medium,
        hiding_zones: ["bus_stops", "local_trains"],
        game_duration: 1,
        day_start_time: "09:00",
        day_end_time: "18:00"
      }

      assert {:ok, %GameSettings{} = settings} = Games.create_game_settings(valid_attrs)
      assert settings.units == :iso
      assert settings.game_size == :medium
      assert settings.hiding_zones == ["bus_stops", "local_trains"]
      assert settings.game_duration == 1
      assert settings.day_start_time == "09:00"
      assert settings.day_end_time == "18:00"
    end
  end

  describe "players" do
    test "create_player/1 with valid data creates a player" do
      game = game_fixture()

      valid_attrs = %{
        name: "Jane Smith",
        is_creator: false,
        game_id: game.id
      }

      assert {:ok, %Player{} = player} = Games.create_player(valid_attrs)
      assert player.name == "Jane Smith"
      assert player.is_creator == false
      assert player.game_id == game.id
    end

    test "get_player/1 returns the player with given id" do
      game = game_fixture()
      player = player_fixture(game.id, %{name: "Jane Smith"})
      assert %Player{id: id} = Games.get_player(player.id)
      assert id == player.id
    end

    test "add_player_to_game/2 adds a player to a game" do
      game = game_fixture()
      assert {:ok, %Player{} = player} = Games.add_player_to_game(game.id, "Jane Smith")
      assert player.name == "Jane Smith"
      assert player.game_id == game.id
      assert player.is_creator == false
    end

    test "remove_player_from_game/1 removes a player from a game" do
      game = game_fixture()
      player = player_fixture(game.id, %{name: "Jane Smith"})
      assert {:ok, %Player{}} = Games.remove_player_from_game(player.id)
      assert Games.get_player(player.id) == nil
    end
  end

  describe "token management" do
    test "generate_token/2 generates a token for WebSocket authentication" do
      game_id = Ecto.UUID.generate()
      player_id = Ecto.UUID.generate()
      token = Games.generate_token(game_id, player_id)
      assert is_binary(token)
    end

    test "verify_token/2 verifies a token for WebSocket authentication" do
      game_id = Ecto.UUID.generate()
      player_id = Ecto.UUID.generate()
      token = Games.generate_token(game_id, player_id)
      assert {:ok, ^player_id} = Games.verify_token(token, game_id)
    end

    test "verify_token/2 returns error for invalid game_id" do
      game_id = Ecto.UUID.generate()
      other_game_id = Ecto.UUID.generate()
      player_id = Ecto.UUID.generate()
      token = Games.generate_token(game_id, player_id)
      assert {:error, :invalid_game} = Games.verify_token(token, other_game_id)
    end

    test "verify_token/2 returns error for invalid token" do
      game_id = Ecto.UUID.generate()
      assert {:error, :invalid} = Games.verify_token("invalid_token", game_id)
    end
  end
end
