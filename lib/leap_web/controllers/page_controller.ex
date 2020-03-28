defmodule LeapWeb.PageController do
  use LeapWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
