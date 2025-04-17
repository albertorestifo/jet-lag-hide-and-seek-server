defmodule JetLagServer.Games.Location do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "locations" do
    field :name, :string
    field :type, :string
    field :coordinates, {:array, :float}
    field :bounding_box, {:array, :float}
    field :osm_id, :string
    field :osm_type, :string

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :type, :coordinates, :bounding_box, :osm_id, :osm_type])
    |> validate_required([:name, :coordinates])
    |> validate_length(:coordinates, is: 2, message: "must contain exactly longitude and latitude")
    |> validate_length(:bounding_box, is: 4, message: "must contain [minLon, minLat, maxLon, maxLat]")
  end
end
