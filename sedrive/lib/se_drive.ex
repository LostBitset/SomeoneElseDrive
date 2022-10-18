defmodule SEDrive do
  @moduledoc """
  Documentation for `SEDrive`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SEDrive.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Just a test for now.
  """
  def main do
    cache = SEDrive.Conn.Sources.toyota
    SEDrive.Conn.Supervisor.start_link([])
    loc = ["xfakesto=blahtest56", "time=#{System.monotonic_time()}"]
    IO.puts "Using location: #{cache.url.(loc)}"
    num = IO.gets "Enter a number: "
    {num, "\n"} = Integer.parse(num)
    IO.puts "Writing..."
    SEDrive.Conn.Supervisor.write_dyn(cache, loc, num)
    IO.puts "Reading..."
    res = SEDrive.Conn.Supervisor.read_destroy_dyn(cache, loc)
    IO.puts "Decoded from cache: #{inspect res}"
  end
end

