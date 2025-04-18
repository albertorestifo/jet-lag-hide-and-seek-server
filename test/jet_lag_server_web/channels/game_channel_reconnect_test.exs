defmodule JetLagServerWeb.GameChannelReconnectTest do
  use JetLagServerWeb.ChannelCase

  alias JetLagServer.Games
  alias JetLagServer.Games.Structs
  alias JetLagServerWeb.UserSocket

  setup do
    # Create a game
    game = JetLagServer.GamesFixtures.game_fixture()

    # Get the creator player
    creator = Enum.find(game.players, fn p -> p.is_creator end)

    # Generate a token for the creator
    token = Games.generate_token(game.id, creator.id)

    %{game: game, creator: creator, token: token}
  end

  test "sends game_state event when a client joins", %{game: game, creator: creator, token: token} do
    # Connect to the socket
    {:ok, socket} = connect(UserSocket, %{})

    # Join the game channel
    {:ok, _reply, _socket} = subscribe_and_join(socket, "games:#{game.id}", %{"token" => token})

    # Assert that we receive a game_state event
    assert_push "game_state", %Structs.GameUpdatedEvent{game: game_state}

    # Verify the game state contains the expected data
    assert game_state.id == game.id
    assert game_state.code == game.code
    assert game_state.status == game.status

    # Verify the game state contains the creator player
    creator_in_state = Enum.find(game_state.players, fn p -> p.id == creator.id end)
    assert creator_in_state != nil
    assert creator_in_state.name == creator.name
    assert creator_in_state.is_creator == true
  end
end
