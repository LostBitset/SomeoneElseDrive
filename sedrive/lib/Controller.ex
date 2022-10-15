defmodule Controller do
  @moduledoc """
  The controller that interacts with a cache,
  and allows you to use it as a mutable array.
  """

  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  def block_size, do: 8
  def block_count, do: 4
  def total_size do
    block_size() * block_count()
  end

  @doc """
  The main loop for the process.
  The state is queued instructions (the map keys are blocks)
  """
  @spec loop(%{integer => [SEDrive.Instr.t]}) :: no_return
  defp loop(queued) do
    receive do

