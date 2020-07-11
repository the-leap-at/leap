defmodule LeapWeb.CurrentUserPlug do
  import Plug.Conn

  alias Leap.Accounts
  alias Leap.Accounts.Schema.User

  def init(opts), do: opts

  def call(conn, _params) do
    case Pow.Plug.current_user(conn) do
      %User{id: current_user_id} = current_user ->
        current_user = user_authenticated(current_user)

        conn
        |> put_session(:current_user_id, current_user_id)
        |> put_session(:live_socket_id, "users_socket:#{current_user.id}")
        |> assign(:current_user, current_user)

      _ ->
        conn
        |> delete_session(:live_socket_id)
        |> delete_session(:current_user_id)
    end
  end

  defp user_authenticated(%User{state: :new} = user),
    do: Accounts.transition_user_state_to!(user, :authenticated)

  defp user_authenticated(user), do: user
end
