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
    num = IO.gets "Enter a number: "
    {num, "\n"} = Integer.parse(num)
    {width, loc} = {8, ["xfakesto=blahtest56", "time=#{System.monotonic_time()}"]}
    IO.puts "Storing at location: #{cache.url.(loc)}"
    SEDrive.Conn.Supervisor.write_integer(cache, loc, num, width)
    res = SEDrive.Conn.Supervisor.read_destroy_integer(cache, loc, width)
    IO.puts "Decoded from cache: #{inspect res}"
  end
end

