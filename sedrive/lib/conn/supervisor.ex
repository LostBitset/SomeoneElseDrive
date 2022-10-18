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

  @typep nni :: non_neg_integer

  @doc """
  Write a fixed-width integer to the cache at a location
  This uses the _bitidx query parameter
  """
  @spec write_integer(Cache.t, Cache.query, nni, nni) :: nil
  def write_integer(cache, loc, num, width) do
    0..(width - 1)
    |> Enum.flat_map(fn bit ->
      mask = 1 <<< bit
      if (num &&& mask) != 0 do
        [
          Task.async(fn ->
            read_and_set(cache, ["_bitidx=#{bit}" | loc])
          end)
        ]
      else
        []
      end
    end)
    |> Enum.each(&Task.await/1)
    nil
  end

  @doc """
  Read a fixed-width integer from the cache at a location
  This uses the _bitidx query parameter
  """
  @spec read_destroy_integer(Cache.t, Cache.query, nni) :: nni
  def read_destroy_integer(cache, loc, width) do
    0..(width - 1)
    |> Enum.map(fn bit ->
      {
        bit,
        Task.async(fn ->
          read_and_set(cache, ["_bitidx=#{bit}" | loc])
        end)
      }
    end)
    |> Enum.map(fn {bit, task} -> {bit, Task.await(task)} end)
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

  @doc """
  Write an integer of unknown width to the cache at a location
  This uses the _bitidx and _ufield query parameters
  """
  @spec write_dyn(Cache.t, Cache.query, nni) :: nil
  def write_dyn(cache, loc, num) do
    width = bit_size_nni(num)
    write_integer(cache, ["_ufield=len" | loc], width, 16)
    write_integer(cache, ["_ufield=dat" | loc], num, width)
    nil
  end

  @doc """
  Read an integer of unknown width from the cache at a location
  This uses the _bitidx and _ufield query parameters
  """
  @spec read_destroy_dyn(Cache.t, Cache.query) :: nni
  def read_destroy_dyn(cache, loc) do
    width = read_destroy_integer(cache, ["_ufield=len" | loc], 16)
    read_destroy_integer(cache, ["_ufield=dat" | loc], width)
  end

  defp bit_size_nni(num) do
    num |> :binary.encode_unsigned |> bit_size
  end

  @doc """
  Write a string to the cache at a location
  This uses the _bitidx and _ufield query parameters
  """
  @spec write_string(Cache.t, Cache.query, String.t) :: nil
  def write_string(cache, loc, str) do
    bin = :binary.decode_unsigned(str)
    write_dyn(cache, loc, bin)
    nil
  end

  @doc """
  Read a string from the cache at a location
  This uses the _bitidx and _ufield query parameters
  """
  @spec read_destroy_string(Cache.t, Cache.query) :: String.t
  def read_destroy_string(cache, loc) do
    bin = read_destroy_dyn(cache, loc)
    :binary.encode_unsigned(bin)
  end
end

