defmodule LeapWeb.EditAnswerLive do
  @moduledoc "Initiate update for paths"
  use LeapWeb, :live
  use TypedStruct

  alias LeapWeb.AnswerView

  def mount(%{"path_id" => path_id}, _session, socket) do
    {:ok, assign(socket, path_id: path_id)}
  end

  def render(assigns) do
    Phoenix.View.render(AnswerView, "edit_answer.html", assigns)
  end
end
