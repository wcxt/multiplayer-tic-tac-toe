defmodule TicTacToe.Registry do
  def start_link(_) do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def child_spec(_) do
    Registry.child_spec(keys: :unique, name: __MODULE__)
  end

  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  def lookup(key) do
    Registry.lookup(__MODULE__, key)
  end

  def select(spec) do
    Registry.select(__MODULE__, spec)
  end

  def keys(pid) do
    Registry.keys(__MODULE__, pid)
  end
end
