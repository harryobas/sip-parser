defmodule SIPParser do
  @moduledoc """
  The SIPParses module takes a SIP request and parses it to a native data structure and can do
  basic operations on the SIP message.
  """
  @type t :: %__MODULE__{
          headers: term(),
          body: binary(),
          start_line: term()
        }
  defstruct [:headers, :body, :start_line]

  @doc """
  Parses a raw SIP request to the internal representation.
  """
  @spec parse(binary()) :: {:ok, t} | {:error, term()}
  def parse(sip_message) do
    parsed_message =
      String.split(sip_message, "\r\n")
      |> clean_raw_message()
      |> extract_headers_body_start_line()

    h = hd(parsed_message)
    b = Enum.at(parsed_message, 1)
    sl = List.last(parsed_message)

    {:ok, %__MODULE__{headers: h,  body: b, start_line: sl}}

    end

  @doc """
  Gets the userpart from the URI which is present in the Request-Line. The Request-Line is the
  first line of the SIP request.
  """
  @spec get_request_user(t) :: binary()
  def get_request_user(parsed_sip_message) do
    user =
      parsed_sip_message.start_line
      |> String.split()
      |> Enum.at(1)
      |> String.split("@")
      |> List.first()
      |> String.split(":")
      |> List.last()
    user
  end

  @doc """
  Confirms if a certain SIP method is allowed or not for this User-Agent. This is signalled by the
  User-Agent in the `Allow`-header.
  """
  @spec allowed?(t, binary()) :: boolean()
  def allowed?(parsed_sip_message,  method) do
    is_allowed =
      parsed_sip_message.headers["Allow"]
      |> String.split(",")
      |> Enum.map(fn x -> String.trim x end)
      |> Enum.member?(method)

     is_allowed
    end

   defp clean_raw_message(raw_message) do
    message =
      raw_message
      |> Enum.reject(fn x -> x == "\n" end)
      |> Enum.reject(fn x -> x == "" end)
    message
  end

  defp extract_headers_body_start_line(message) do
    start_line = hd(message)
    headers_and_body = tl(message)

    body =
      headers_and_body
      |>
      Enum.reject(fn x -> String.contains? x, ":" end)
      |>
      Enum.join( ",")

    headers =
      headers_and_body
      |>
      Enum.reject(fn x -> String.contains? x, "=" end)
      |>
      Enum.map(fn x ->
      n = String.split(x, ":")
      {hd(n), hd(tl(n))}
    end)
    |>
    Enum.into(%{})

  [headers, body, start_line]

  end

end
