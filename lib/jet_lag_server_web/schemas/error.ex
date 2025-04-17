defmodule JetLagServerWeb.Schemas.Error do
  @moduledoc """
  Schema for error responses.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Error",
    description: "Error response",
    type: :object,
    required: [:code, :message],
    properties: %{
      code: %Schema{type: :string, description: "Error code", example: "invalid_request"},
      message: %Schema{type: :string, description: "Error message", example: "Invalid game code"},
      details: %Schema{
        type: :object,
        description: "Additional error details",
        nullable: true
      }
    }
  })
end
