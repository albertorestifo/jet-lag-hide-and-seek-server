defmodule JetLagServer.Games.GameTest do
  use JetLagServer.DataCase

  alias JetLagServer.Games.Game

  describe "game schema" do
    test "changeset with valid attributes" do
      valid_attrs = %{
        code: "ABC123",
        status: "waiting",
        location_id: Ecto.UUID.generate(),
        settings_id: Ecto.UUID.generate()
      }

      changeset = Game.changeset(%Game{}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid code format" do
      invalid_attrs = %{
        # lowercase not allowed
        code: "abc123",
        status: "waiting",
        location_id: Ecto.UUID.generate(),
        settings_id: Ecto.UUID.generate()
      }

      changeset = Game.changeset(%Game{}, invalid_attrs)
      assert %{code: ["has invalid format"]} = errors_on(changeset)
    end

    test "changeset with invalid status" do
      invalid_attrs = %{
        code: "ABC123",
        status: "invalid_status",
        location_id: Ecto.UUID.generate(),
        settings_id: Ecto.UUID.generate()
      }

      changeset = Game.changeset(%Game{}, invalid_attrs)
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "generate_code returns a 6-character code" do
      code = Game.generate_code()
      assert String.length(code) == 6
      assert code =~ ~r/^[A-Z0-9]{6}$/
    end
  end
end
