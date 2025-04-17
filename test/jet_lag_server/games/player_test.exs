defmodule JetLagServer.Games.PlayerTest do
  use JetLagServer.DataCase

  alias JetLagServer.Games.Player

  describe "player schema" do
    test "changeset with valid attributes" do
      valid_attrs = %{
        name: "John Doe",
        is_creator: true,
        game_id: Ecto.UUID.generate()
      }

      changeset = Player.changeset(%Player{}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset with missing name" do
      invalid_attrs = %{
        is_creator: true,
        game_id: Ecto.UUID.generate()
      }

      changeset = Player.changeset(%Player{}, invalid_attrs)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
