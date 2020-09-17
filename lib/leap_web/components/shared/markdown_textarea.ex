defmodule LeapWeb.Components.Shared.MarkdownTextarea do
  @moduledoc """
  Markdown textarea with preview.
  Should be hightly configurable and extensible. Eg be able to add atoolbar to add predefined text
  """

  use LeapWeb, :component

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
