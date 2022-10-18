defmodule SEDrive.Rw.Supervisor do
  @moduledoc """
  A the read-write interface for refresh-based caching storage backend
  of SEDrive.
  """
  use Supervisor
  alias SEDrive.Conn.Cache, as: Cache
  alias SEDrive.Refresh.Supervisor, as: RefreshSup
  alias SEDrive.Rw.Server, as: RwServer

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      RefreshSup,
      RwServer
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end

