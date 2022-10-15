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

  @type instr :: {:get, integer, pid} | {:set, integer, boolean}

  @spec loop(pid, %{integer => [instr]}) :: no_return
  defp loop(comms, queued) do
    receive do
      {:instr, instr} ->
        {:ok, block, block_instr} = make_block_instr(instr)
        loop(comms, %{queued | block => block_instr})
      {:refresh_block, block} ->
        buf = read_block(comms, block)
        buf = apply_instrs(buf, queued[block], block)
        write_block(comms, block, buf)
        queued(comms, Map.delete(queued, block))
      :refresh ->
        if block_count() != 0 do
          send self(), {:refresh_block, 0}
        end
        loop(comms, queued)
    end
  end

  @spec make_block_instr(instr) :: {:ok, integer, instr} | {:err, :instr_out_of_range}
  defp make_block_instr({:get, index, caller}) do
    block = div(index, block_size())
    index = rem(index, block_size())
    if block < block_count() do
      {:ok, block, {:get, index, caller}}
    else
      {:err, :instr_out_of_range}
    end
  end
  defp make_block_instr({:set, index, val}) do
    block = div(index, block_size())
    index = rem(index, block_size())
    if block < block_count() do
      {:ok, block, {:set, index, val}}
    else
      {:err, :instr_out_of_range}
    end
  end

  @spec apply_instrs(bitstring, [instr]) :: bitstring
  defp apply_instrs(buf, instrs, block) do
    Enum.reduce(instrs, buf, &apply_instr(&1, &2, block))
  end

  @spec apply_instr(instr, bitstring, integer) :: bitstring
  defp apply_instr({:get, index, caller}, buf, block) do
    bit = index_bitstring(buf, index)
    index = make_not_block_instr(block, {:get, index, caller})
    send caller, {:got, index, bit}
    buf
  end
  defp apply_instr({:set, index, val}, buf, _block) do
    set_bitstring(buf, index, val)
  end
end

