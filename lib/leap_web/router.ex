defmodule LeapWeb.Router do
  use LeapWeb, :router
  use Pow.Phoenix.Router

  use Pow.Extension.Phoenix.Router,
    extensions: [PowEmailConfirmation, PowResetPassword, PowPersistentSession]

  use PowAssent.Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LeapWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug PowAssent.Plug.Reauthorization,
      handler: PowAssent.Phoenix.ReauthorizationPlugHandler
  end

  pipeline :skip_csrf_protection do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
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
    pipe_through :skip_csrf_protection

    pow_assent_authorization_post_callback_routes()
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
    pow_extension_routes()
    pow_assent_routes()
  end

  scope "/", LeapWeb do
    pipe_through [:browser, :current_user]
    # can use live_action when needed
    # https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Router.html#live/4-actions-and-live-navigation
    #    live "/", AppLive, :home
    # the live action will be available in the assigns
    # %{assigns: %{live_action: :home}}

    live "/", AppLive
    live "/:container/:post_id", AppLive

    # routes that require authentication
    pipe_through [:protected]
  end

  # Other scopes may use custom stacks.
  # scope "/api", LeapWeb do
  #   pipe_through :api
  # end
end
