defmodule Leap.Accounts.Schema.User do
  @moduledoc """
  Generated by POW
  Moved to namespace
  """
  use Ecto.Schema
  use Pow.Ecto.Schema
  use PowAssent.Ecto.Schema

  use Pow.Extension.Ecto.Schema,
    extensions: [PowEmailConfirmation, PowResetPassword, PowPersistentSession]

  import Ecto.Changeset
  import EctoEnum

  alias Leap.Accounts.Users
  alias Leap.Group.Schema.Category
  alias Leap.Group.Schema.UserCategory
  alias Leap.Content.Schema.Post

  defguard is_present(value) when is_binary(value) and bit_size(value) > 0

  defenum StateEnum, ["new", "authenticated", "display_name_set", "onboarded"]

  defmodule StateMachine do
    @moduledoc "State machine for User. See Machinary docs for guards or callbacks if needed"
    use Machinery,
      states: StateEnum.__valid_values__(),
      transitions: %{
        new: :authenticated,
        authenticated: :display_name_set,
        display_name_set: :onboarded
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
    field :state, StateEnum, default: "new", read_after_writes: true
    field :picture_url, :string
    field :display_name, :string

    many_to_many :fav_categories, Category, join_through: UserCategory
    has_many :posts, Post

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
  end

  def user_identity_changeset(user, user_identity, attrs, user_id_attrs) do
    user
    |> changeset_user_details(attrs)
    |> pow_assent_user_identity_changeset(user_identity, attrs, user_id_attrs)
  end

  def changeset_user_details(user, attrs) do
    user
    |> cast(attrs, [:picture_url, :display_name])
    |> validate_format(:display_name, ~r/^(?!.*[_]{2})[A-Za-z]\w*[A-Za-z0-9]$/)
    |> validate_length(:display_name, min: 3, max: 50)
    |> unique_constraint(:display_name)
    |> put_picture_url(attrs)
  end

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
