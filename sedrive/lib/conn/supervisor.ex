defmodule SEDrive.Conn.Supervisor do
  use Supervisor
  import Bitwise
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
  @spec read_and_set(Cache.t, Cache.query) :: Cache.cache_result
  def read_and_set(cache, query) do
    req = Finch.build(:get, cache.url.(query))
    with {:ok, %Finch.Response{headers: headers}} <- Finch.request(req, MainFinch)
    do
      cache.hit?.(headers)
    else
      {:error, exn} -> {:err, exn}
    end
  end

  @doc """
  Write a fixed-width integer to the cache at a location
  This uses the _bitidx query parameter
  """
  @spec write_integer(Cache.t, Cache.query, integer, integer) :: nil
  def write_integer(cache, loc, num, width) do
    0..(width - 1)
    |> Enum.each(fn bit ->
      mask = 1 <<< bit
      if (num &&& mask) != 0 do
        read_and_set(cache, ["_bitidx=#{bit}" | loc])
      end
    end)
    nil
  end

  @doc """
  Read a fixed-width integer from the cache at a location
  This uses the _bitidx query parameter
  """
  @spec read_destroy_integer(Cache.t, Cache.query, integer) :: integer
  def read_destroy_integer(cache, loc, width) do
    0..(width - 1)
    |> Enum.map(fn bit ->
      {bit, read_and_set(cache, ["_bitidx=#{bit}" | loc])}
    end)
    |> Enum.map(fn {bit, {:ok, bool}} ->
      if bool do
        {bit, 1}
      else
        {bit, 0}
      end
    end)
    |> Enum.map(fn {bit, value} -> value <<< bit end)
    |> Enum.sum()
  end
end

