defmodule JetLagServerWeb.ApiSpec do
  @moduledoc """
  API Specification for the JetLag Hide & Seek game.
  """

  alias OpenApiSpex.{Components, Info, OpenApi, Paths, Server, SecurityScheme}
  alias JetLagServerWeb.{Endpoint, Router}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        # Populate the Server info from the endpoint
        %Server{url: Endpoint.url()}
      ],
      info: %Info{
        title: "JetLag Hide & Seek Game API",
        version: "1.0.0",
        description: "API for the JetLag Hide & Seek game companion app"
      },
      # Populate the paths from the router
      paths: Paths.from_router(Router),
      components: %Components{
        schemas: %{
          # We'll define our schemas here
          Error: JetLagServerWeb.Schemas.Error,
          Location: JetLagServerWeb.Schemas.Location,
          GameSettings: JetLagServerWeb.Schemas.GameSettings,
          Player: JetLagServerWeb.Schemas.Player,
          Game: JetLagServerWeb.Schemas.Game,
          CreateGameRequest: JetLagServerWeb.Schemas.CreateGameRequest,
          CreateGameResponse: JetLagServerWeb.Schemas.CreateGameResponse,
          JoinGameRequest: JetLagServerWeb.Schemas.JoinGameRequest,
          JoinGameResponse: JetLagServerWeb.Schemas.JoinGameResponse,
          CheckGameExistsResponse: JetLagServerWeb.Schemas.CheckGameExistsResponse,
          LocationSearchResult: JetLagServerWeb.Schemas.LocationSearchResult,
          LocationBoundaries: JetLagServerWeb.Schemas.LocationBoundaries
        },
        securitySchemes: %{
          bearerAuth: %SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT",
            description: "Enter the token you received when creating or joining a game"
          }
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
