defmodule JetLagServerWeb.GameChannelTest do
  use JetLagServerWeb.ChannelCase

  alias JetLagServerWeb.UserSocket
  alias JetLagServer.Games

  import JetLagServer.GamesFixtures

  setup do
    # Create a game with a creator
    game = game_fixture()
    creator = List.first(game.players)

    # Generate a token for the creator
    token = Games.generate_token(game.id, creator.id)

    # Create a socket and join the channel
    {:ok, socket} = connect(UserSocket, %{})

    {:ok, _game_data, socket} =
      subscribe_and_join(socket, "games:#{game.id}", %{"token" => token})

    # Return the game, creator, token, and socket
    {:ok, %{game: game, creator: creator, token: token, socket: socket}}
  end

  test "ping replies with pong", %{socket: socket} do
    ref = push(socket, "ping", %{})
    assert_reply ref, :ok, %{type: "pong", data: %{}}
  end

  test "join_game adds a player to the game", %{socket: socket, game: game} do
    # Push a join_game message
    ref = push(socket, "join_game", %{"playerName" => "Jane Smith"})
    assert_reply ref, :ok, %{playerId: player_id}

    # Verify the player was added to the game
    assert player_id =~ ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
    player = Games.get_player(player_id)
    assert player.name == "Jane Smith"
    assert player.game_id == game.id
    assert player.is_creator == false

    # Verify a player_joined broadcast was sent
    assert_broadcast "player_joined", %{
      player: %{id: ^player_id, name: "Jane Smith", isCreator: false}
    }
  end

  test "start_game starts the game when the creator initiates it", %{socket: socket, game: game} do
    # Push a start_game message
    ref = push(socket, "start_game", %{})
    assert_reply ref, :ok, %{startedAt: started_at}

    # Verify the game was started
    updated_game = Games.get_game(game.id)
    assert updated_game.status == "active"
    assert updated_game.started_at != nil

    # Verify a game_started broadcast was sent
    assert_broadcast "game_started", %{startedAt: ^started_at}
  end

  test "start_game returns error when non-creator tries to start the game", %{game: game} do
    # Create a new player
    {:ok, player} = Games.add_player_to_game(game.id, "Jane Smith")
    token = Games.generate_token(game.id, player.id)

    # Connect and join as the new player
    {:ok, socket} = connect(UserSocket, %{})

    {:ok, _game_data, socket} =
      subscribe_and_join(socket, "games:#{game.id}", %{"token" => token})

    # Push a start_game message
    ref = push(socket, "start_game", %{})
    assert_reply ref, :error, %{reason: "only the creator can start the game"}

    # Verify the game was not started
    updated_game = Games.get_game(game.id)
    assert updated_game.status == "waiting"
    assert updated_game.started_at == nil
  end

  test "leave_game removes a player from the game", %{game: game} do
    # Create a new player
    {:ok, player} = Games.add_player_to_game(game.id, "Jane Smith")
    token = Games.generate_token(game.id, player.id)

    # Connect and join as the new player
    {:ok, socket} = connect(UserSocket, %{})

    {:ok, _game_data, socket} =
      subscribe_and_join(socket, "games:#{game.id}", %{"token" => token})

    # Push a leave_game message
    push(socket, "leave_game", %{})

    # The channel will stop, so we can't assert a reply
    # Instead, wait a bit and then check if the player was removed
    :timer.sleep(100)

    # Verify the player was removed from the game
    assert Games.get_player(player.id) == nil

    # Verify a player_left broadcast was sent
    assert_broadcast "player_left", %{playerId: player_id}
    assert player_id == player.id
  end

  test "join fails with invalid token", %{game: game} do
    # Try to join with an invalid token
    {:ok, socket} = connect(UserSocket, %{})

    assert {:error, %{reason: "authentication required"}} =
             subscribe_and_join(socket, "games:#{game.id}", %{})
  end

  test "join fails with token for different game", %{game: game, creator: creator} do
    # Create another game
    other_game = game_fixture()

    # Generate a token for the creator but for the other game
    token = Games.generate_token(other_game.id, creator.id)

    # Try to join with a token for a different game
    {:ok, socket} = connect(UserSocket, %{})

    assert {:error, %{reason: :invalid_game}} =
             subscribe_and_join(socket, "games:#{game.id}", %{"token" => token})
  end
end
