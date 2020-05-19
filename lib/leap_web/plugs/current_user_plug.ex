defmodule LeapWeb.CurrentUserPlug do
  import Plug.Conn

  alias Leap.Accounts.Schema.User

  def init(opts), do: opts

  def call(conn, _params) do
    case Pow.Plug.current_user(conn) do
      %User{id: current_user_id} ->
        put_session(conn, :current_user_id, current_user_id)

      _ ->
        put_session(conn, :current_user_id, nil)
    end
  end
end
