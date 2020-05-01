defmodule LeapWeb.Components.EditPost.EditCategory do
  @moduledoc """
  - Edit posts category
  - The categories are predefined and added in the DB with a migration (at least for now)
  """
  use LeapWeb, :component
  use TypedStruct

  alias Leap.Content
  alias Leap.Content.Schema.Post
  alias Leap.Group
  alias Leap.Group.Schema.Category

  defmodule State do
    @moduledoc false
    @debounce 1000

    @typedoc "EditPost Component state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :debounce, integer(), default: @debounce
      field :post, Post.t(), enforce: true
      field :categories, [Category.t()], default: []
    end
  end

  defguard is_present(value) when is_binary(value) and bit_size(value) > 0

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{id: component_id, post: post, categories: categories}, socket) do
    state = %State{
      component_id: component_id,
      post: post,
      categories: categories
    }

    {:ok, assign(socket, %{state: state, category: post.category})}
  end

  def handle_event(
        "search_category",
        %{"value" => category_query_term},
        %{assigns: %{state: state}} = socket
      )
      when is_present(category_query_term) do
    state = %State{state | categories: Group.search_category(category_query_term)}
    {:noreply, assign(socket, :state, state)}
  end

  def handle_event(
        "search_category",
        _params,
        %{assigns: %{state: state}} = socket
      ) do
    state = %State{state | categories: Group.all(Category)}
    {:noreply, assign(socket, :state, state)}
  end

  def handle_event(_catch_all, _params, socket) do
    {:noreply, socket}
  end
end
