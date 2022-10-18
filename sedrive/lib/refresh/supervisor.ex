defmodule SEDrive.Refresh.Supervisor do
  @moduledoc """
  A supervisor that updates a known location stored on the cache.
  """
  use Supervisor
  alias SEDrive.Conn.Cache, as: Cache
  alias SEDrive.Conn.Supervisor, as: ConnSup

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      SEDrive.Conn.Supervisor
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  @typep nni :: non_neg_integer

  @typedoc """
  Error return types from the refresh/3 function.
  """
  @type refresh_error :: {:err, :in_use} | {:err, :other, Exception.t}

  @doc """
  Refresh a known location on the cache.
  """
  @spec refresh(Cache.t, Cache.query, String.t | nil) :: {:ok, String.t} | refresh_error
  def refresh(cache, loc, new_contents \\ nil) do
    curr_period = period_now()
    with {:ok, period_claimed?} <- claim_period(cache, loc, curr_period)
    do
      if !period_claimed? do
        if new_contents == nil do
          with {:ok, src_period} <- find_src_period(cache, loc, curr_period - 1)
          do
            period_old = Integer.to_string(src_period)
            old = ConnSup.read_destroy_string(cache, ["_period=#{period_old}" | loc])
            period_new = Integer.to_string(curr_period)
            ConnSup.write_string(cache, ["_period=#{period_new}" | loc], old)
            {:ok, old}
          else
            {:err, exn} -> {:err, :other, exn}
          end
        else
          period = Integer.to_string(curr_period)
          ConnSup.write_string(cache, ["_period=#{period}" | loc], new_contents)
          {:ok, new_contents}
        end
      else
        {:err, :in_use}
      end
    else
      {:err, exn} -> {:err, :other, exn}
    end
  end

  @typedoc """
  Error return types from the create_new/3 function.
  """
  @type create_new_error :: {:err, :exists_claimed} | {:err, :other, Exception.t}
  @doc """
  Create a new location on the cache that can be refreshed.
  """
  @spec create_new(Cache.t, Cache.query, String.t) :: :ok | create_new_error
  def create_new(cache, loc, contents) do
    curr_period = period_now()
    with {:ok, period_claimed?} <- claim_period(cache, loc, curr_period)
    do
      if !period_claimed? do
        period = Integer.to_string(curr_period)
        ConnSup.write_string(cache, ["_period=#{period}" | loc], contents)
        :ok
      else
        {:err, :exists_claimed}
      end
    else
      {:err, exn} -> {:err, :other, exn}
    end
  end

  @spec claim_period(Cache.t, Cache.query, nni) :: Cache.cache_result
  defp claim_period(cache, loc, period) do
    period = Integer.to_string(period)
    ConnSup.read_and_set(cache, ["_rspper=has", "_period=#{period}" | loc])
  end

  @spec find_src_period(Cache.t, Cache.query, nni) :: {:ok, nni} | {:err, Exception.t}
  defp find_src_period(cache, loc, period) do
    with {:ok, period_claimed?} <- claim_period(cache, loc, period)
    do
      if !period_claimed? do
        find_src_period(cache, loc, period - 1)
      else
        {:ok, period}
      end
    else
      {:err, exn} -> {:err, exn}
    end
  end

  @spec period_now :: nni
  defp period_now do
    System.monotonic_time(:second) |> time_to_period
  end

  @spec time_to_period(nni) :: nni
  defp time_to_period(secs) do
    secs |> div(60)
  end
end

