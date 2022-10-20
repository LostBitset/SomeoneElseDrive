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
    cache = SEDrive.Conn.Sources.astrohamster
    RwSup.start_link(cache)
    key = IO.gets "Enter a key to identify this store: "
    key = String.trim(key)
    prefix = ["_xsedrv=t", "_verstr=v1", "_identt=stdkey", "_stdkey=#{key}"]
    main(cache, prefix)
  end

  def main(cache, prefix) do
    what = IO.gets "Read (r), write (w), or quit (q): "
    what = what
           |> String.trim()
           |> String.downcase()
    case what do
      "q" ->
        IO.puts "(seeya)"
      "w" ->
        filename = IO.gets "What file do you want to write to: "
        filename = String.trim(filename)
        loc = file(filename, prefix)
        already_exists = IO.gets("Does this file exist already? (y/n): ")
        if String.trim(already_exists) == "y" do
          read_file_at(loc)
        end
        contents = IO.gets "What do you want to write: "
        IO.puts "Writing..."
        RwSup.write(loc, contents)
        IO.puts "Ok. Your write has only been saved locally, it won't be saved to SEDrive right away."
        main(cache, prefix)
      "r" ->
        filename = IO.gets "What file do you want to read: "
        filename = String.trim(filename)
        loc = file(filename, prefix)
        read_file_at(loc)
        main(cache, prefix)
      _ ->
        IO.puts "Not sure what that is, answer one of {\"r\", \"w\", \"q\"}."
        main(cache, prefix)
    end
  end

  defp file(filename, prefix) do
    ["_filenm=#{filename}", "_isfile=t" | prefix]
  end

  defp read_file_at(loc) do
    IO.puts "Reading..."
    RwSup.read(loc, self())
    contents = receive do
      {:got, _loc, contents} -> contents
    end
    IO.puts "This file currently contains: <BEGIN>"
    IO.puts contents
    IO.puts "<END>"
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

