defmodule LeapWeb.Router do
  use LeapWeb, :router
  use Pow.Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LeapWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :current_user do
    plug LeapWeb.CurrentUserPlug
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  scope "/", LeapWeb do
    pipe_through [:browser, :protected, :current_user]

    live "/", AppLive, :home

    live "/:container/:post_id", AppLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", LeapWeb do
  #   pipe_through :api
  # end
end
