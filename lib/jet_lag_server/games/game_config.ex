defmodule JetLagServer.Games.GameConfig do
  @moduledoc """
  Static configuration for game settings based on game size and units.
  """

  # Define game size enum values
  @game_sizes [:small, :medium, :large]

  # Define units enum values
  @units [:ansi, :iso]

  # Default location update frequency in seconds
  @default_location_update_frequency 5

  @doc """
  Returns the hiding zone size in meters based on game size and units.
  """
  def hiding_zone_size(game_size, units) do
    case {game_size, units} do
      {:small, :ansi} -> 200
      {:small, :iso} -> 250
      {:medium, :ansi} -> 500
      {:medium, :iso} -> 600
      {:large, :ansi} -> 1000
      {:large, :iso} -> 1200
      _ -> raise "Invalid game size or units: #{game_size}, #{units}"
    end
  end

  @doc """
  Returns the list of valid game sizes.
  """
  def valid_game_sizes, do: @game_sizes

  @doc """
  Returns the list of valid units.
  """
  def valid_units, do: @units

  @doc """
  Returns the default location update frequency in seconds.
  """
  def default_location_update_frequency, do: @default_location_update_frequency
end
