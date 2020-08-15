defmodule Scrip.Response do
  defmodule Error do
    @moduledoc """
    Module dealing with error responses from the App Store
    """
    @type t :: %__MODULE__{
            environment: :sandbox | :production | nil,
            message: String.t(),
            status: integer
          }

    @doc """
    The `#{__MODULE__}` struct

    Contains

    * `:status` - status code returned by the App Store
    * `:message` - message explaining the status code
    * `:environment` - which environment the error was generated (sometimes nil)
    """
    @enforce_keys [:status, :message]
    defstruct [:status, :message, :environment]

    @spec new(integer, String.t(), String.t()) :: Scrip.Response.Error.t()
    def new(status, message, environment) do
      %__MODULE__{
        environment: Scrip.Util.to_environment(environment),
        status: status,
        message: message
      }
    end
  end

  @moduledoc """
  Handles the JSON data returned in the response from the App Store.
  """

  @typedoc """
  The environment for which the receipt was generated.

  #### Possible values:

   * `:sandbox`
   * `:production`
  """
  @type environment :: :sandbox | :production

  @status_map %{
    0 => "The request is valid",
    21_000 => "The request to the App Store was not made using the HTTP POST request method.",
    21_001 => "This status code is no longer sent by the App Store.",
    21_002 =>
      "The data in the receipt-data property was malformed or the service experienced a temporary issue. Try again.",
    21_003 => "The receipt could not be authenticated.",
    21_004 =>
      "The shared secret you provided does not match the shared secret on file for your account.",
    21_005 => "The receipt server was temporarily unable to provide the receipt. Try again.",
    21_006 =>
      "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response. Only returned for iOS 6-style transaction receipts for auto-renewable subscriptions.",
    21_007 =>
      "This receipt is from the test environment, but it was sent to the production environment for verification.",
    21_008 =>
      "This receipt is from the production environment, but it was sent to the test environment for verification.",
    21_009 => "Internal data access error. Try again later.",
    21_010 => "The user account cannot be found or has been deleted."
  }
  @typedoc """
  The status of the app receipt.

  #### Possible values:

  #{
    Enum.reduce(@status_map, "", fn {key, value}, acc ->
      "#{acc}\n * `#{key}` - #{value}\n"
    end)
  }


  See: https://developer.apple.com/documentation/appstorereceipts/status
  """
  @type status :: 0 | 21_000..21_010

  @typedoc """
  An array that contains all in-app purchase transactions.

  Only returned for receipts that contain auto-renewable subscriptions.

  https://developer.apple.com/documentation/appstorereceipts/responsebody/latest_receipt_info
  """
  @type latest_receipt_info :: [Scrip.IAPReceipt.t()]

  @typedoc """
  The JSON data returned in the response from the App Store.

  See: https://developer.apple.com/documentation/appstorereceipts/responsebody
  """
  @type t :: %__MODULE__{
          environment: environment,
          latest_receipt_info: latest_receipt_info | nil,
          latest_receipt: String.t(),
          message: String.t(),
          pending_renewal_info: [Scrip.PendingRenewalInfo.t()] | nil,
          receipt: Scrip.Receipt.t(),
          status: status
        }

  @doc """
  The `#{__MODULE__}` struct

  """
  @enforce_keys [
    :environment,
    :latest_receipt_info,
    :latest_receipt,
    :message,
    :receipt,
    :status
  ]
  defstruct [
    :environment,
    :latest_receipt_info,
    :latest_receipt,
    :message,
    :pending_renewal_info,
    :receipt,
    :status
  ]

  @spec new(response :: map) :: Scrip.Response.t() | Scrip.Response.Error.t()
  @doc """
  Converts response map to `#{__MODULE__}` or`#{__MODULE__}.Error` struct

  """
  def new(%{"status" => status} = response) when status in [0, 21_006] do
    %__MODULE__{
      environment: Scrip.Util.to_environment(response["environment"]),
      latest_receipt_info:
        response["latest_receipt_info"] &&
          Enum.map(response["latest_receipt_info"], &Scrip.IAPReceipt.new/1),
      latest_receipt: response["latest_receipt"],
      message: build_message(response["status"]),
      pending_renewal_info:
        response["pending_renewal_info"] &&
          Enum.map(response["pending_renewal_info"], &Scrip.PendingRenewalInfo.new/1),
      receipt: Scrip.Receipt.new(response["receipt"]),
      status: response["status"]
    }
  end

  def new(response) do
    __MODULE__.Error.new(
      response["status"],
      build_message(response["status"]),
      response["environment"]
    )
  end

  def build_message(status) do
    Map.get(@status_map, status, "Unknown status (#{inspect(status)}) was returned")
  end
end
