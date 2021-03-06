defmodule LeapWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use LeapWeb, :controller
      use LeapWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: LeapWeb

      import Plug.Conn
      import LeapWeb.Gettext
      alias LeapWeb.Router.Helpers, as: Routes
      import Phoenix.LiveView.Controller
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/leap_web/templates",
        namespace: LeapWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import LeapWeb.ErrorHelpers
      import LeapWeb.Gettext
      alias LeapWeb.Router.Helpers, as: Routes

      import Phoenix.LiveView.Helpers
    end
  end

  def mailer_view do
    quote do
      use Phoenix.View,
        root: "lib/leap_web/templates",
        namespace: LeapWeb

      use Phoenix.HTML
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import LeapWeb.Gettext
    end
  end

  def live do
    quote do
      use Phoenix.LiveView
      use Phoenix.HTML
      import LeapWeb.ErrorHelpers
      import LeapWeb.Gettext
      alias LeapWeb.Router.Helpers, as: Routes

      def handle_info(
            {:perform_action, {component_module, component_id, action_title, payload}},
            socket
          ) do
        send_update(component_module, id: component_id, action: action_title, payload: payload)
        {:noreply, socket}
      end

      def handle_info(
            {:delay_action, delay,
             {component_module, component_id, action_title, _payload} = action},
            socket
          ) do
        ref_key =
          to_string(component_module) <> to_string(component_id) <> to_string(action_title)

        if Map.get(socket.assigns, ref_key) do
          Process.cancel_timer(Map.get(socket.assigns, ref_key))
        end

        ref = Process.send_after(self(), {:perform_action, action}, delay)

        {:noreply, assign(socket, ref_key, ref)}
      end
    end
  end

  def component do
    quote do
      use Phoenix.LiveComponent
      use Phoenix.HTML
      import LeapWeb.ErrorHelpers
      import LeapWeb.Gettext
      alias LeapWeb.Router.Helpers, as: Routes

      def send_to_main(action, payload, state) do
        send(self(), {:perform_action, {state.module, state.id, action, payload}})
      end

      def delay_send_to_main(delay, action, payload, state) do
        send(self(), {:delay_action, delay, {state.module, state.id, action, payload}})
      end

      def send_notification(sender_id, type, message, display_timeout \\ :default) do
        send(
          self(),
          {:perform_action,
           {LeapWeb.Components.Container.Notifications, "notifications", :notify,
            %{
              sender_id: sender_id,
              type: type,
              message: message,
              display_timeout: display_timeout
            }}}
        )
      end

      def markdown_to_html(body) do
        safe =
          body
          |> to_string()
          |> Earmark.as_html!(breaks: true)
          |> HtmlSanitizeEx.markdown_html()

        raw({:safe, safe})
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
