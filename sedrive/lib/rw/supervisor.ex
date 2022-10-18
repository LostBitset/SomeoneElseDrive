defmodule SEDrive.Rw.Supervisor do
  @moduledoc """
  A the read-write interface for refresh-based caching storage backend
  of SEDrive.
  """
  use Supervisor
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


end

