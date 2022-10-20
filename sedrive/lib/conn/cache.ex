defmodule SEDrive.Conn.Cache do
  @moduledoc """
  A struct representing a cache that can be accessed
  (and used to store data).
  """

  @typedoc """
  The type of headers that the hit? function will see
  """
  @type headers :: [{name :: String.t, value :: String.t}]

  @typedoc """
  The return type of hit?
  """
  @type cache_result :: {:ok, boolean} | {:err, Exception.t}

  @typedoc """
  The input to url, a query string represented as a list of strings
  which should be of the form {key}={value}
  """
  @type query :: [String.t]

  @type t :: %__MODULE__{
    url: (query -> String.t),
    hit?: (headers -> cache_result)
  }

  @enforce_keys [:url, :hit?]
  defstruct [:url, :hit?]

  @doc """
  A helper function that allows you to check just one header
  """
  @spec from_single_header(String.t, String.t, String.t) :: t
  def from_single_header(url, header_name, hit_value) do
    %__MODULE__{
      url: & "#{url}?#{Enum.join(&1, "&")}",
      hit?: &is_header(&1, header_name, hit_value)
    }
  end

  @doc """
  A helper function that allows you to check just one header,
  looking for whether it contains a value rather than an exact match
  """
  @spec from_single_header_contains(String.t, String.t, String.t) :: t
  def from_single_header_contains(url, header_name, hit_value) do
    %__MODULE__{
      url: & "#{url}?#{Enum.join(&1, "&")}",
      hit?: (fn resp ->
        is_header(resp, header_name, hit_value, &String.contains?/2)
      end)
    }
  end

  defmodule CachingHeaderNotFoundError do
    @moduledoc """
    An exception that should be raised when the header used to indicate the status
    of the cache was not found in the response.
    """
    defexception message: "The header used to indicate cache status was not found."
  end

  defp is_header(headers, target_name, target_value, cmp \\ nil) do
    pair = Enum.find(headers, fn {name, _} -> name == target_name end)
    with {_, value} <- pair
    do
      if cmp == nil do
        {:ok, value == target_value}
      else
        {:ok, cmp.(value, target_value)}
      end
    else
      nil -> {:err, CachingHeaderNotFoundError}
    end
  end
end

