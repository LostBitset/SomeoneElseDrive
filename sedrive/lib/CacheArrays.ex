defmodule CacheArrays do
  @moduledoc """
  Allow you to use a cache as a (bit)array.
  You can read from a location, destroying it.
  You can also write to a location that doesn't already exist.
  """
  use GenServer
  alias SEDrive.ArrayInstrs, as: Instr

  @type state :: [Instr.t]

  @impl true
  @spec init(:ok) :: {:ok, state}
  def init(:ok) do
    {:ok, []}
  end

  @impl true

end

