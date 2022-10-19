defmodule SEDrive do
  @moduledoc """
  Documentation for `SEDrive`.
  """
  alias SEDrive.Rw.Supervisor, as: RwSup

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
    RwSup.start_link(cache)
    key = IO.gets "Enter a key to identify this store: " |> String.trim()
    prefix = ["_xsedrv=t", "_verstr=v1", "_identt=stdkey", "_stdkey=#{key}"]
    main(cache, prefix)
  end

  def main(cache, prefix) do
    what = IO.gets "Read (r), write (w), or quit (q): "
           |> String.trim()
           |> String.downcase()
    case what do
      _ ->
        IO.puts "Not sure what that is, answer one of {\"r\", \"w\", \"q\"}."
        main(cache, prefix)
    end
  end

  defp file(filename, prefix) do
    ["_filenm=#{filename}", "_isfile=t" | prefix]
  end

  @doc """
  A simple test for the refresh-based raw storage system
  """
  def test_refresh_system do
    {cache, loc} = setup()
    SEDrive.Refresh.Supervisor.start_link([])
    IO.puts "Creating..."
    SEDrive.Refresh.Supervisor.create_new(cache, loc, "<initial contents>")
    IO.puts "Waiting..."
    :timer.sleep(6000)
    IO.puts "Refreshing..."
    res = SEDrive.Refresh.Supervisor.refresh(cache, loc)
    IO.puts "Decoded from cache: #{inspect res}"
    new = IO.gets "Enter new contents: "
    IO.puts "Waiting..."
    :timer.sleep(6000)
    IO.puts "Refreshing..."
    res = SEDrive.Refresh.Supervisor.refresh(cache, loc, new)
    IO.puts "Decoded from cache: #{inspect res}"
    IO.puts "Waiting (for multiple periods)..."
    :timer.sleep(11000)
    IO.puts "Refreshing..."
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

