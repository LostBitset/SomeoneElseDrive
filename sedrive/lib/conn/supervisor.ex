defmodule SEDrive.Conn.Supervisor do
  use Supervisor
  alias SEDrive.Conn.Cache, as: Cache

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Finch, name: MainFinch}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Access the cache, which both reads the value and sets it to true
  (where true means that it can be found in the cache)
  """
  @spec read_and_set(Cache.t, String.t) :: Cache.cache_result
  def read_and_set(cache, query) do
    req = Finch.build(:get, cache.url.(query))
    with {:ok, %Finch.Response{headers: headers}} <- Finch.request(req, MainFinch)
    do
      cache.hit?.(headers)
    else
      {:error, exn} -> {:err, exn}
    end
  end
end

