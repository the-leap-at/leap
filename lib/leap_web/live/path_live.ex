defmodule LeapWeb.PathLive do
  @moduledoc "Initiate update for paths"
  use LeapWeb, :live
  use TypedStruct

  alias LeapWeb.Live.PathView

  def mount(%{"path_id" => path_id}, _session, socket) do
    {:ok, assign(socket, path_id: path_id)}
  end

  def render(assigns) do
    Phoenix.View.render(PathView, "path.html", assigns)
  end
end
