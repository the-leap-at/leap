defmodule LeapWeb.Components.EditPath do
  @moduledoc """
  - Updates paths

  """
  use LeapWeb, :component
  use TypedStruct

  alias Leap.Answers
  alias Leap.Answers.Schema.Path

  defmodule State do
    @moduledoc false
    @debounce 1000

    @typedoc "EditPath Component state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :debounce, integer(), default: @debounce
      field :path, Path.t(), enforce: true
      field :path_changeset, Ecto.Changeset.t(Path.t())
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :update_path, params: path_params}, %{assigns: %{state: state}} = socket) do
    case Answers.update_path(state.path, path_params) do
      {:ok, path} ->
        state = %State{state | path: path, path_changeset: Answers.change_path(path)}

        {:ok, assign(socket, :state, state)}

      {:error, changeset} ->
        state = %State{state | path_changeset: changeset}

        {:ok, assign(socket, :state, state)}
    end
  end

  def update(%{id: component_id, path: path}, socket) do
    state = %State{
      component_id: component_id,
      path: path,
      path_changeset: Answers.change_path(path)
    }

    {:ok, assign(socket, :state, state)}
  end

  @doc "Live updates a draft path"
  def handle_event("update_path", %{"path" => path_params}, %{assigns: %{state: state}} = socket) do
    case state.path do
      %Path{state: state} when state in [:new, :draft] ->
        send(
          self(),
          {:perform_action, {__MODULE__, state.component_id, :update_path, path_params}}
        )

        {:noreply, socket}

      %Path{state: :published} ->
        path = Answers.validate_publish_path(state.path, path_params)
        state = %State{state | path_changeset: path}

        IO.inspect(state.path_changeset)

        {:noreply, assign(socket, :state, state)}
    end
  end

  @doc "Publish a draft path or already published path (edit)"
  def handle_event("publish_path", %{"path" => path_params}, %{assigns: %{state: state}} = socket) do
    case Answers.publish_path(state.path, path_params) do
      {:ok, path} ->
        state = %State{state | path: path, path_changeset: Answers.change_path(path)}
        socket = assign(socket, :state, state)
        {:noreply, push_patch(socket, to: Routes.live_path(socket, LeapWeb.PathLive, path.id))}

      {:error, changeset} ->
        state = %State{state | path_changeset: changeset}
        {:noreply, assign(socket, :state, state)}
    end
  end

  defp markdown_textarea(form, state, socket) do
    live_component(socket, LeapWeb.Components.MarkdownTextarea,
      id: "#{state.component_id}_content",
      debounce: state.debounce,
      form: form,
      field: :content,
      value: state.path.content
    )
  end
end
