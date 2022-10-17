defmodule SEDrive.Controller do
  use GenServer

  @typedoc """
  An instruction about what to do with a file
  """
  @type instr :: {:read, caller :: pid} | {:write, new_contents :: String.t}

  @type state :: %{String.t => [instr]}

  @impl true
  @spec init(:ok) :: {:ok, state}
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:read, file}, _from, state) do
    tail =
      if Map.has_key?(state, file) do
        []
      else
        state[file]
      end
    {:noreply, 
  end
end

