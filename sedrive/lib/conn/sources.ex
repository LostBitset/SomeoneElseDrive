defmodule SEDrive.Conn.Sources do
  @moduledoc """
  Some caches that can be used to store data.
  The only public members of this module should be of type
  SEDrive.Conn.Cache.t (aliased as Cache), and should be spec'd as such.
  """
  alias SEDrive.Conn.Cache, as: Cache

  @spec toyota :: Cache.t
  def toyota do
    Cache.from_single_header(
      "https://www.toyota.com/etc.clientlibs/tcom/clientlibs/clientlib-carouselcontainerv2.min.d32f29c0e74277cda235ee0fdb49af7c.js",
      "x-cache",
      "Hit from cloudfront"
    )
  end

  @spec organclearinghouse :: Cache.t
  def organclearinghouse do
    base = "https://assets.squarespace.com/@sqs/polyfiller/1.2.2/modern.js"
    %Cache{
      url: & "#{base}?#{Enum.join(&1, "&")}",
      hit?: &String.contains?(&1, "HIT")
    }
  end
end

