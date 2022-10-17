defmodule SEDrive.Controller do
  use GenServer
  alias SEDrive.ArrayInstrs, as: Instr

  @type state :: %{String.t => [Instr.t]}

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
  def handle_cast({:refresh, file, next_period}, state) do
    if Map.has_key?(state, file) do
      refresh_file(file, state[file], next_period)
      {:noreply, Map.delete(state, file)}
    else
      refresh_file(file, [], next_period)
      {:noreply, state}
    end
  end

  @spec cons_instr(state, String.t, Instr.t) :: state
  defp cons_instr(state, file, instr) do
    tail =
      if Map.has_key?(state, file) do
        []
      else
        state[file]
      end
    %{state | file => [instr | tail]}
  end

  @spec refresh_file(String.t, [Instr.t], integer) :: nil
  def refresh_file(file, instrs, next_period) do
    "not yet defined"
  end
end
