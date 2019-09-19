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
      String.split(sip_message, "\n\n")
      |> clean_raw_message()
      |> extract_headers_body_start_line()

    h = List.first(parsed_message)
    b = hd(tl(parsed_message))
    sl = List.last(parsed_message)

    {:ok, %__MODULE__{headers: h,  body: b, start_line: sl}}

    end

  @doc """
  Gets the userpart from the URI which is present in the Request-Line. The Request-Line is the
  first line of the SIP request.
  """
  @spec get_request_user(t) :: binary()
  def get_request_user(_parsed_sip_message) do
    "user"
  end

  @doc """
  Confirms if a certain SIP method is allowed or not for this User-Agent. This is signalled by the
  User-Agent in the `Allow`-header.
  """
  @spec allowed?(t, binary()) :: boolean()
  def allowed?(_parsed_sip_message, _method) do
    false
  end

  defp clean_raw_message(raw_message) do
    message = Enum.reject raw_message, fn x -> x == "\n" end
    message = Enum.reject message, fn x -> x == "" end
    message
    end

  defp extract_headers_body_start_line(message) do
    start_line = hd(message)
    headers_body = tl(message)
    body = Enum.reject headers_body, fn x -> String.contains? x, ":" end
    body = Enum.join(body, ",")

    headers = Enum.reject headers_body, fn x -> String.contains? x, "=" end
    headers = Enum.map headers, fn x ->
      n = String.split(x, ":")
      {hd(n), hd(tl(n))}
    end

    headers = Enum.into(headers, %{})

    [headers, body, start_line]

  end

end
