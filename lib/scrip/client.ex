defmodule Scrip.Client do
  @moduledoc """
  Http client behaviour

  """
  @type url :: String.t()
  @type payload :: String.t()

  @callback post(
              url,
              payload :: payload,
              headers :: [{String.t(), String.t()}],
              opts :: []
            ) ::
              {:ok, status :: integer, headers :: [{String.t(), String.t()}], body :: String.t()}
              | {:error, String.t()}
end
