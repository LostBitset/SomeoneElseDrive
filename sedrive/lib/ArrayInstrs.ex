defmodule ArrayInstrs do
  @moduledoc """
  Instructions that operate on (bit)arrays.
  """

  @type t :: {:read, caller :: pid} | {:write, contents :: String.t}
end

