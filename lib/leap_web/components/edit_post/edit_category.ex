defmodule LeapWeb.Components.EditPost.EditCategory do
  @moduledoc """
  - Edit posts category
  - The categories are predefined and added in the DB with a migration (at least for now)
  """
  use LeapWeb, :component
  use TypedStruct

  alias Leap.Group
  alias Leap.Group.Schema.Category

  defmodule State do
    @moduledoc false
    @debounce 500

    @typedoc "EditPost Component state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :action, list() | keyword(), default: [:init]
      field :edit_post_component_id, String.t(), enforce: true
      field :debounce, integer(), default: @debounce
      field :value, String.t(), default: ""
      field :form, Phoenix.HTML.Form.t(), enforce: true
      field :category, Category.t(), enforce: true
      field :categories, [Category.t()], default: []
    end
  end

  defguard is_present(value) when is_binary(value) and bit_size(value) > 0

  def mount(socket) do
    {:ok, socket}
  end

  def update(
        %{
          action: [:init],
          id: component_id,
          edit_post_component_id: edit_post_component_id,
          form: form,
          category: category
        },
        socket
      ) do
    value = category && category.name

    state = %State{
      component_id: component_id,
      edit_post_component_id: edit_post_component_id,
      value: value,
      form: form,
      category: category,
      categories: Group.all(Category)
    }

    {:ok, assign(socket, %{state: state})}
  end

  def update(
        %{form: form, category: category},
        %{assigns: %{state: state}} = socket
      ) do
    value = category && category.name
    state = %State{state | form: form, category: category, value: value}

    {:ok, assign(socket, :state, state)}
  end

  # this needs to be replaced with update coming from parent
  def handle_event(
        "search_category",
        %{"category" => %{"query_term" => term}},
        %{assigns: %{state: state}} = socket
      )
      when is_present(term) do
    state = %State{state | action: [category: :search], categories: Group.search_category(term)}
    {:noreply, assign(socket, :state, state)}
  end

  def handle_event(
        "search_category",
        _params,
        %{assigns: %{state: state}} = socket
      ) do
    state = %State{state | action: [category: :search], categories: Group.all(Category)}
    {:noreply, assign(socket, :state, state)}
  end

  def handle_event(
        "update_category",
        %{"category_id" => category_id},
        %{assigns: %{state: state}} = socket
      ) do
    send(
      self(),
      {:perform_action,
       {LeapWeb.Components.EditPost, state.edit_post_component_id, [post: :update],
        %{category_id: category_id}}}
    )

    {:noreply, socket}
  end

  def handle_event("prevent_submit", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(_catch_all, _params, socket) do
    {:noreply, socket}
  end

  defp category_name(%Category{name: name}), do: name
  defp category_name(_), do: nil
end
