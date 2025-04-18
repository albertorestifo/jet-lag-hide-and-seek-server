defmodule JetLagServer.Geocoding.CachedBoundary do
  @moduledoc """
  Schema for cached location boundaries.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  
  schema "cached_boundaries" do
    field :osm_type, :string
    field :osm_id, :string
    field :data, :string
    
    timestamps()
  end
  
  @doc false
  def changeset(cached_boundary, attrs) do
    cached_boundary
    |> cast(attrs, [:osm_type, :osm_id, :data])
    |> validate_required([:osm_type, :osm_id, :data])
    |> unique_constraint([:osm_type, :osm_id])
  end
end
