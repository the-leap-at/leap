defmodule LeapWeb.PathLive do
  @moduledoc "Initiate update for paths"
  use LeapWeb, :live
  use TypedStruct

  alias LeapWeb.Live.PathView

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"path_id" => path_id, "action" => "edit"}, _uri, socket) do
    path_component =
      live_component(socket, LeapWeb.Components.EditPath,
        id: "edit_path" <> path_id,
        path_id: path_id
      )

    {:noreply, assign(socket, path_component: path_component)}
  end

  def handle_params(%{"path_id" => path_id}, _uri, socket) do
    path_component =
      live_component(socket, LeapWeb.Components.ShowPath,
        id: "show_path" <> path_id,
        path_id: path_id
      )

    {:noreply, assign(socket, path_component: path_component)}
  end

  def render(assigns) do
    Phoenix.View.render(PathView, "path.html", assigns)
  end
end
