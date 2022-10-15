defmodule SEDrive.Access.CacheTalker do
  @behaviour SEDrive.Access.CacheTalk

  def check(_query) do
    {:err, "not yet implemented"}
  end
end

