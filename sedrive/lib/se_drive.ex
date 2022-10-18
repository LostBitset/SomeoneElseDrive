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
    {cache, loc} = setup()
    SEDrive.Refresh.Supervisor.start_link([])
    IO.puts "Creating..."
    SEDrive.Refresh.Supervisor.create_new(cache, loc, "<initial contents>")
    IO.puts "Waiting..."
    :timer.sleep(6000)
    IO.puts "Reading..."
    res = SEDrive.Refresh.Supervisor.refresh(cache, loc)
    IO.puts "Decoded from cache: #{inspect res}"
  end

  @doc """
  A simple test for storing strings.
  """
  def test_strings do
    {cache, loc} = setup()
    SEDrive.Conn.Supervisor.start_link([])
    str = IO.gets "Enter some text: "
    IO.puts "Writing..."
    SEDrive.Conn.Supervisor.write_string(cache, loc, str)
    IO.puts "Reading..."
    res = SEDrive.Conn.Supervisor.read_destroy_string(cache, loc)
    IO.puts "Decoded from cache: #{res}"
  end

  defp setup do
    cache = SEDrive.Conn.Sources.toyota
    loc = ["xfakesto=blahtest56", "time=#{System.monotonic_time()}"]
    IO.puts "Using location: #{cache.url.(loc)}"
    {cache, loc}
  end
end

