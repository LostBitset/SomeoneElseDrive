defmodule SEDrive.Refresh.Supervisor do
  @moduledoc """
  A supervisor that updates known files stored on the cache.
  """
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {SEDrive.Conn.Supervisor, name: MainConn}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end

