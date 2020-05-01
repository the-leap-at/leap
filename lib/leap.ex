defmodule Leap do
  @moduledoc """
  Leap keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def context do
    quote do
      alias Leap.Repo
      @spec get(Ecto.Queryable.t(), id :: integer()) :: Ecto.Schema.t() | nil
      def get(queryable, id), do: Repo.get(queryable, id)

      @spec get!(Ecto.Queryable.t(), id :: integer()) :: Ecto.Schema.t() | nil
      def get!(queryable, id), do: Repo.get(queryable, id)

      @spec all(Ecto.Queryable.t()) :: [Ecto.Schema.t()]
      def all(queryable), do: Repo.all(queryable)

      @spec with_preloads([Ecto.Schema.t()] | Ecto.Schema.t() | nil, Keyword.t() | list()) ::
              [Ecto.Schema.t()] | Ecto.Schema.t() | nil
      def with_preloads(schema, preloads), do: Repo.preload(schema, preloads)
    end
  end

  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      def strip_html_tags(changeset, key) do
        case fetch_change(changeset, key) do
          {:ok, value} ->
            clean_value =
              value
              |> HtmlSanitizeEx.strip_tags()
              |> replace_lt_gt()

            put_change(changeset, key, clean_value)

          _ ->
            changeset
        end
      end

      # this is needed to display the signs in the editor
      # but most important, to display the Markdown quote, like `> some quote`
      # TODO: find some better solution
      defp replace_lt_gt(string) do
        string
        |> String.replace("&gt;", ">", global: true)
        |> String.replace("&lt;", "<", global: true)
      end
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
