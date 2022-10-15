defmodule Controller do
  @moduledoc """
  The controller that interacts with a cache,
  and allows you to use it as a mutable array.
  """

  def start_link do
    Task.start_link(fn ->
      loop(start_comms(), %{})
    end)
  end

  def block_size, do: 8
  def block_count, do: 4
  def total_size do
    block_size() * block_count()
  end

  @type instr :: {:get, integer} | {:set, integer, boolean}

  @spec loop(pid, %{integer => [instr]}) :: no_return
  defp loop(comms, queued) do
    receive do
      {:instr, instr} ->
        {block, block_instr} = make_block_instr(instr)
        loop(comms, %{queued | block => block_instr})
      {:refresh_block, block} ->
        buf = read_block(comms, block)
        buf = apply_instrs(queued[block], buf)
        write_block(comms, block, buf)
        queued(comms, Map.delete(queued, block))
      :refresh ->
        if block_count() != 0 do
          send self(), {:refresh_block, 0}
        end
        loop(comms, queued)
    end
  end
end

