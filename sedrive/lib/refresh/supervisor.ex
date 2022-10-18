defmodule SEDrive.Refresh.Supervisor do
  @moduledoc """
  A supervisor that updates a known location stored on the cache.
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

  @typep nni :: non_neg_integer

  @doc """
  Refresh a known location on the cache.
  """
  @spec refresh(Cache.t, Cache.query, String.t | nil) :: String.t
  def refresh(cache, loc, new_contents \\ nil) do
    "not yet implemented"
  end

  @spec to_nonneg(integer) :: nni
  defp to_nonneg(any_num) do
    if any_num >= 0 do
      (any_num * 2) + 1
    else
      -any_num * 2
    end
  end

  @spec period_now :: nni
  defp period_now do
    System.monotonic_time(:second) |> time_to_period |> to_nonneg()
  end

  @spec time_to_period(nni) :: nni
  defp time_to_period(secs) do
    secs |> div(60)
  end

  @spec decrement_nnm(nni) :: nni
  defp decrement_nnm(num) do
    if rem(num, 2) == 1 do
      # positive case
      res = num - 2
      if res == -1 do
        # positive -> negative
        0
      else
        # normal positive
        res
      end
    else
      # negative case
      num - 2
    end
  end
end

