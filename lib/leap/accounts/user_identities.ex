defmodule Leap.Accounts.UserIdentities do
  @moduledoc """
  TODO
  PowAssent context module. Need this as workaround if user already registered with email and password, cannot register again with OAUTH
  Check when this is addressed: https://github.com/pow-auth/pow_assent/issues/115 and retry without this context
  """
  use PowAssent.Ecto.UserIdentities.Context,
    repo: Leap.Repo,
    user: Leap.Accounts.Schema.User

  alias Leap.Repo
  alias Ecto.Multi
  alias Leap.Accounts.Users
  alias Leap.Accounts.Schema.User

  def create_user(user_identity_params, user_params, user_id_params) do
    with {:ok, user} <- Users.fetch_user(user_params["email"]),
         {:ok, %{user: user}} <-
           Repo.transaction(update_user_and_identity(user, user_params, user_identity_params)) do
      {:ok, user}
    else
      _ ->
        pow_assent_create_user(user_identity_params, user_params, user_id_params)
    end
  end

  defp update_user_and_identity(user, user_params, user_identity_params) do
    Multi.new()
    |> Multi.update(:user, User.changeset_user_details(user, user_params))
    |> Multi.run(:user_identity, fn _repo, %{user: user} ->
      pow_assent_upsert(user, user_identity_params)
    end)
  end
end
