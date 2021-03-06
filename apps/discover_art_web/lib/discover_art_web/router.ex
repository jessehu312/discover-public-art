defmodule DiscoverArtWeb.Router do
  use DiscoverArtWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", DiscoverArtWeb do
    pipe_through :api

    resources "/users", UserController, only: [:index, :create, :show, :update, :delete]
    scope "/check_ins" do
      get    "/:user_id",                CheckInController, :show
      post   "/:user_id/:public_art_id", CheckInController, :create
      delete "/:user_id/:public_art_id", CheckInController, :delete
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: DiscoverArtWeb.Telemetry
    end
  end

  scope "/auth", DiscoverArtWeb do
    post "/login", AuthController, :create
    get "/login", AuthController, :new
  end

  scope "/", DiscoverArtWeb do
    pipe_through :browser

    get "/map", MapController, :index
    get "/*path", PageController, :index
  end
end
