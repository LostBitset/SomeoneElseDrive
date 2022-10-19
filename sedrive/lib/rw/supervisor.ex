defmodule SEDrive.Rw.Supervisor do
  @moduledoc """
  A the read-write interface for refresh-based caching storage backend
  of SEDrive.
  """
  use Supervisor
  alias SEDrive.Conn.Cache, as: Cache
  alias SEDrive.Refresh.Supervisor, as: RefreshSup
  alias SEDrive.Rw.Server, as: RwServer

  def start_link(cache, opts \\ []) do
    Supervisor.start_link(__MODULE__, {:ok, cache}, opts)
  end

  @impl true
  def init({:ok, cache}) do
    children = [
      RefreshSup,
      {RwServer, cache}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec read(Cache.query, pid) :: :ok
  def read(loc, caller) do
    GenServer.cast(rw_server(), {:read, loc, caller})
  end

  @spec write(Cache.query, String.t) :: :ok
  def write(loc, contents) do
    GenServer.cast(rw_server(), {:write, loc, contents})
  end

  @spec rw_server() :: pid
  defp rw_server do
    [_, {_, server, _, _}] = Supervisor.which_children(__MODULE__)
    server
  end
end

