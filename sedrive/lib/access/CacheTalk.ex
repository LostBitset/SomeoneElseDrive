defmodule SEDrive.Access.CacheTalk do
  @doc """
  Asks the cache, returning whether or not the value existed.
  Note that this also sets the value to 1.
  Think of this as a "get and set to 1" primitive.
  """
  @callback check(query :: %{String.t => String.t}) :: {:ok, prev :: boolean} | {:err, reason :: term}
end

