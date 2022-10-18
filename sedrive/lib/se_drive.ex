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
    str = IO.gets "Enter some text: "
    IO.puts "Writing..."
    SEDrive.Conn.Supervisor.write_string(cache, loc, str)
    IO.puts "Reading..."
    res = SEDrive.Conn.Supervisor.read_destroy_string(cache, loc)
    IO.puts "Decoded from cache: #{res}"
  end
end

