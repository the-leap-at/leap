defmodule LeapWeb.PathLive do
  @moduledoc "Initiate update for paths"
  use LeapWeb, :live
  use TypedStruct

  alias Leap.Answers
  alias Leap.Answers.Schema.Path

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [path: nil, path_component: nil]}
  end

  def handle_params(%{"path_id" => path_id, "action" => "edit"}, _uri, socket) do
    path = Answers.get!(Path, path_id)

    path_component =
      live_component(socket, LeapWeb.Components.EditPath,
        id: "edit_path" <> to_string(path_id),
        path: path
      )

    {:noreply, assign(socket, path_component: path_component)}
  end

  def handle_params(%{"path_id" => path_id}, _uri, socket) do
    path = Answers.get!(Path, path_id)

    path_component =
      live_component(socket, LeapWeb.Components.ShowPath,
        id: "edit_path" <> to_string(path_id),
        path: path
      )

    {:noreply, assign(socket, path_component: path_component)}
  end
end
