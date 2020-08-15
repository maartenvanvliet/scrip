defmodule Scrip.Config do
  @moduledoc """
  Handles the configuration

  """

  @typedoc """
  Opts to be passed in to the `verify/3` function. Will be merged with the config
  """
  @type opts ::
          {:client, client}
          | {:json_encoder, json_encoder}
          | {:production_url, String.t()}
          | {:sandbox_url, String.t()}
          | {:password, password}
          | {:request_opts, keyword()}

  @typedoc """
  Your app's shared secret (a hexadecimal string).
  Use this field only for receipts that contain auto-renewable subscriptions.
  """
  @type password :: String.t()

  @typedoc """
  Http Client, must implement `Scrip.Client` behaviour

  Defaults to `Scrip.Client.HTTPoison` wrapping `HTTPoison`
  """
  @type client :: module()

  @typedoc """
  Json encoder, must implement `encode!/1`,`decode!/1` functions like Jason does

  Defaults to `Jason`
  """
  @type json_encoder :: module()

  @typedoc """
  Will be passed to the http adapter. Useful for setting timeouts etc.

  Are dependant on the http client
  """
  @type request_opts :: keyword()

  @typedoc """
  Configuration
  """
  @type t :: %__MODULE__{
          client: client(),
          json_encoder: json_encoder(),
          production_url: String.t(),
          sandbox_url: String.t(),
          password: password(),
          request_opts: request_opts()
        }

  @doc """
  Struct that holds the configuration

  See the types for what values can be passed in

  """
  @enforce_keys [:client, :json_encoder, :production_url, :sandbox_url, :password, :request_opts]
  defstruct [:client, :json_encoder, :production_url, :sandbox_url, :password, :request_opts]

  @spec new([opts]) :: Scrip.Config.t()
  @doc """
  Build new config struct. Any key in the struct can be passed in to `new/1` as a keyword list
  to override the defaults.
  """
  def new(opts \\ []) do
    %__MODULE__{
      client: opts[:client] || Scrip.Client.HTTPoison,
      json_encoder: opts[:json_encoder] || Jason,
      production_url: opts[:production_url] || "https://buy.itunes.apple.com/verifyReceipt",
      sandbox_url: opts[:sandbox_url] || "https://sandbox.itunes.apple.com/verifyReceipt",
      password: opts[:password],
      request_opts: opts[:request_ops] || []
    }
    |> validate_presence!(:json_encoder)
    |> validate_presence!(:client)
    |> validate_presence!(:password)
  end

  defp validate_presence!(config, setting) do
    Map.get(config, setting) || raise ArgumentError, "Config setting #{setting} not set"

    config
  end
end
