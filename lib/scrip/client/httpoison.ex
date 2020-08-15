if Code.ensure_loaded?(HTTPoison) do
  defmodule Scrip.Client.HTTPoison do
    @moduledoc false
    @behaviour Scrip.Client

    @impl true
    def post(url, payload, headers, opts) do
      case HTTPoison.post(url, payload, headers, opts) do
        {:ok, %HTTPoison.Response{body: body, headers: headers, status_code: status}} ->
          {:ok, status, headers, body}

        {:error, error} ->
          {:error, error.reason}
      end
    end
  end
end
