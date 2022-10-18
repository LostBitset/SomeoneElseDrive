defmodule SEDrive.Rw.Server do
  @moduledoc """
  An internal GenServer to read and write to SEDrive.
  This should only be used through the supervisor (SEDrive.Rw.Supervisor).
  """
  use GenServer
  alias SEDrive.Conn.Cache, as: Cache
  alias SEDrive.Refresh.Supervisor, as: RefreshSup

  @typedoc """
  Instructions for what to do with something stored on SEDrive.
  """
  @type instr :: %{required(:read) => [pid], optional(:write) => String.t}

  @type state :: {Cache.t, %{Cache.query => instr}}

  def start_link(cache) do
    GenServer.start_link(__MODULE__, cache)
  end

  @impl true
  @spec init(Cache.t) :: {:ok, state}
  def init(cache) do
    {:ok, {cache, %{}}}
  end

  @impl true
  def handle_cast({:read, loc, caller}, {cache, instrs}) do
    new_instr =
      if Map.has_key?(instrs, loc) do
        %{
          instrs[loc] |
          read: [caller | instrs[loc].read]
        }
      else
        %{read: [caller]}
      end
    {:noreply, {cache, %{instrs | loc => new_instr}}}
  end
end

