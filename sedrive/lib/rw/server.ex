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

  @type state :: {Cache.t, %{Cache.query => instr}, [Cache.query]}

  def start_link(cache) do
    GenServer.start_link(__MODULE__, cache, name: __MODULE__)
  end

  @impl true
  @spec init(Cache.t) :: {:ok, state}
  def init(cache) do
    schedule_next_refresh()
    {:ok, {cache, %{}, []}}
  end

  @impl true
  def handle_cast({:read, loc, caller}, {cache, instrs, targets}) do
    new_instr =
      if Map.has_key?(instrs, loc) do
        %{
          instrs[loc] |
          read: [caller | instrs[loc].read]
        }
      else
        %{read: [caller]}
      end
    ret = {:noreply, {cache, Map.put(instrs, loc, new_instr), targets}}
    ret
  end

  @impl true
  def handle_cast({:write, loc, contents}, {cache, instrs, targets}) do
    new_instr =
      if Map.has_key?(instrs, loc) do
        %{
          instrs[loc] |
          write: contents
        }
      else
        %{
          read: [],
          write: contents
        }
      end
    ret = {:noreply, {cache, Map.put(instrs, loc, new_instr), targets}}
    ret
  end

  @impl true
  def handle_info(:try_refresh, {cache, instrs, targets}) do
    remaining = Map.keys(instrs)
                |> Enum.map(fn loc ->
                  {loc, try_refresh(cache, loc, instrs[loc])}
                end)
                |> Enum.reject(fn {_loc, ret} ->
                  with {:ok, refreshed?} <- ret
                  do
                    refreshed?
                  else
                    {:err, exn} -> throw exn
                  end
                end)
                |> Enum.map(fn {loc, _ret} -> loc end)
    targets
    |> Enum.reject(
      &Enum.member?(remaining, &1)
    )
    |> Enum.each(fn loc ->
      try_refresh(cache, loc, %{read: []})
    end)
    instrs = Map.take(instrs, remaining)
    schedule_next_refresh()
    {:noreply, {cache, instrs, targets ++ remaining}}
  end

  @spec try_refresh(Cache.t, Cache.query, instr) :: {:ok, boolean} | {:err, Exception.t}
  defp try_refresh(cache, loc, instr) do
    IO.inspect {:fun, :try_refresh, cache, loc, instr}
    contents = Map.get(instr, :write)
    with {:ok, contents} <- RefreshSup.refresh(cache, loc, contents)
    do
      instr.read
      |> Enum.each(fn caller ->
        send caller, {:got, loc, contents}
      end)
      {:ok, true}
    else
      {:err, :in_use} ->
        {:ok, false}
      {:err, :other, exn} -> {:err, exn}
    end
  end

  @spec schedule_next_refresh() :: nil
  defp schedule_next_refresh do
    Process.send_after(self(), :try_refresh, 2500)
    nil
  end
end

