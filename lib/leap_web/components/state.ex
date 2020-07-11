defmodule LeapWeb.Components.State do
  @callback init(params :: map) :: {:ok, state :: struct()}
  @callback commit(action :: atom(), params :: any(), state :: struct()) ::
              {:ok, state :: struct()}
              | {:ok, {state :: struct(), {message_type :: atom(), message :: binary}}}
              | {:error, message :: binary()}
end
