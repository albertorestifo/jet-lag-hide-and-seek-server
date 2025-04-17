defmodule JetLagServerWeb.Router do
  use JetLagServerWeb, :router

  alias JetLagServerWeb.ApiSpec

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {JetLagServerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: ApiSpec
  end

  scope "/", JetLagServerWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # OpenAPI Specification routes
  scope "/api" do
    pipe_through :api

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  # API routes for the Hide & Seek game
  scope "/api", JetLagServerWeb.API, as: :api do
    pipe_through :api

    post "/games", GameController, :create
    get "/games/:id", GameController, :show
    post "/games/:id/start", GameController, :start
    post "/games/join", GameController, :join
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:jet_lag_server, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: JetLagServerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
