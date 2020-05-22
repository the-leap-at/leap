defmodule Leap.Accounts.Schema.User do
  @moduledoc """
  Generated by POW
  Moved to namespace
  """
  use Ecto.Schema
  use Pow.Ecto.Schema
  use PowAssent.Ecto.Schema
  import Ecto.Changeset
  import EctoEnum

  alias __MODULE__
  alias Leap.Accounts.Users

  defguard is_present(value) when is_binary(value) and bit_size(value) > 0
  defenum StateEnum, ["new", "authenticated", "onbaorded"]

  defmodule StateMachine do
    @moduledoc "State machine for User. See Machinary docs for guards or callbacks if needed"
    use Machinery,
      states: StateEnum.__valid_values__(),
      transitions: %{
        new: :authenticated,
        authenticated: :onbaorded
      }

    def persist(user, next_state) do
      Users.update_state!(user, next_state)
    end
  end

  schema "users" do
    has_many :user_identities, Leap.Accounts.Schema.UserIdentity,
      on_delete: :delete_all,
      foreign_key: :user_id

    pow_user_fields()

    # custom fields
    field :state, StateEnum, default: "new"
    field :picture_url, :string
    field :display_name, :string

    timestamps()
  end

  def user_identity_changeset(user, user_identity, attrs, user_id_attrs) do
    user
    |> cast(attrs, [])
    |> put_state_authenticated(user, user_identity)
    |> put_picture_url(attrs)
    |> pow_assent_user_identity_changeset(user_identity, attrs, user_id_attrs)
  end

  defp put_state_authenticated(changeset, %User{state: "new"}, %{"uid" => uid})
       when is_present(uid) do
    IO.inspect("HEREEEEEEE")
    put_change(changeset, :state, :authenticated)
  end

  defp put_state_authenticated(changeset, _user, _user_identity), do: changeset

  defp put_picture_url(changeset, %{"picture" => picture_url}) do
    put_change(changeset, :picture_url, picture_url)
  end

  defp put_picture_url(changeset, _attrs), do: changeset

  def changeset_state_transition(user, attrs) do
    user
    |> cast(attrs, [:state])
    |> validate_required([:state])
  end

  def changeset_state_transition_error(user, attrs, error) do
    user
    |> cast(attrs, [:state])
    |> validate_required([:state])
    |> add_error(:state, error)
  end
end
