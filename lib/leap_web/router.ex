defmodule LeapWeb.Router do
  use LeapWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {LeapWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LeapWeb do
    pipe_through :browser

    live "/post/:post_id", PostLive
    live "/post/:post_id/:action", PostLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", LeapWeb do
  #   pipe_through :api
  # end
end
