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

  @spec astrohamster :: Cache.t
  def astrohamster do
    Cache.from_single_header(
      "https://www.astrohamster.com/star.gif",
      "x-cache",
      "HIT"
    )
  end

  @spec uk :: Cache.t
  def uk do
    Cache.from_single_header(
      "https://www.parliament.uk/static/fonts/National-LFS-Book.woff2",
      "cf-cache-status",
      "HIT"
    )
  end
end

