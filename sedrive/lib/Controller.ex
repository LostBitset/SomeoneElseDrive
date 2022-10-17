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
  def handle_cast({:read, file, caller}, state) do
    {:noreply, cons_instr(state, file, {:read, caller})}
  end
  def handle_cast({:write, file, contents}, state) do
    {:noreply, cons_instr(state, file, {:write, contents})}
  end

  @spec cons_instr(state, String.t, instr) :: state
  defp cons_instr(state, file, instr) do
    tail =
      if Map.has_key?(state, file) do
        []
      else
        state[file]
      end
    %{state | file => [instr | tail]}
  end
end

