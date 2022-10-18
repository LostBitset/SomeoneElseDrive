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
  @type refresh_error :: {:err, :in_use} | {:err, :no_source} | {:err, :other, Exception.t}

  @doc """
  Refresh a known location on the cache.
  """
  @spec refresh(Cache.t, Cache.query, String.t | nil) :: {:ok, String.t} | refresh_error
  def refresh(cache, loc, new_contents \\ nil) do
    curr_period = period_now()
    with {:ok, period_claimed?} <- claim_period(cache, loc, curr_period)
    do
      if period_claimed? do
        if new_contents == nil do
          src_period = find_src_period(cache, loc, curr_period - 1)
          if src_period == :never_existed do
            {:err, :no_source}
          else
            {:ok, "TODO"}
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

  @spec claim_period(Cache.t, Cache.query, nni) :: Cache.cache_result
  defp claim_period(cache, loc, period) do
    period = Integer.to_string(period)
    ConnSup.read_and_set(cache, ["_rspper=has", "_period=#{period}" | loc])
  end

  @spec find_src_period(Cache.t, Cache.query, nni) :: nni | :never_existed

  @spec period_now :: nni
  defp period_now do
    System.monotonic_time(:second) |> time_to_period
  end

  @spec time_to_period(nni) :: nni
  defp time_to_period(secs) do
    secs |> div(60)
  end
end

