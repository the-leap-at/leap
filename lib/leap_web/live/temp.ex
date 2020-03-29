defmodule LeapWeb.TempLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :msg, "IT WORKS")}
  end

  def render(assigns) do
    ~L"""
    Message: <%= @msg %>
    """
  end
end
