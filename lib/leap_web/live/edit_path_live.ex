defmodule LeapWeb.EditPathLive do
  @moduledoc "Initiate update for paths"
  use LeapWeb, :live
  use TypedStruct

  alias LeapWeb.LiveView

  def mount(%{"path_id" => path_id}, _session, socket) do
    {:ok, assign(socket, path_id: path_id)}
  end

  def render(assigns) do
    Phoenix.View.render(LiveView, "edit_path.html", assigns)
  end
end
