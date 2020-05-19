defmodule Leap.Accounts.Schema.UserIdentity do
  use Ecto.Schema
  use PowAssent.Ecto.UserIdentities.Schema, user: Leap.Accounts.Schema.User

  schema "user_identities" do
    pow_assent_user_identity_fields()

    timestamps()
  end
end
