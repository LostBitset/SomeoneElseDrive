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
      {RefreshSup, cache},
      RwServer
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec read(Cache.query, pid) :: :ok
  def read(loc, caller) do
    GenServer.cast(RefreshSup, {:read, loc, caller})
  end

  @spec write(Cache.query, String.t) :: :ok
  def write(loc, contents) do
    GenServer.cast(RefreshSup, {:write, loc, contents})
  end
end

