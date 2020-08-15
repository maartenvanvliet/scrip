defmodule Scrip.Receipt do
  @moduledoc """
  Refers to auto-renewable subscription renewals that are open or failed in the past.

  See: https://developer.apple.com/documentation/appstorereceipts/responsebody/pending_renewal_info#properties
  """

  @typedoc """
  Refers to auto-renewable subscription renewals that are open or failed in the past.

  See: https://developer.apple.com/documentation/appstorereceipts/responsebody/pending_renewal_info#properties
  """
  @type t :: %__MODULE__{
          adam_id: integer,
          app_item_id: integer,
          application_version: String.t(),
          bundle_id: String.t(),
          download_id: integer,
          in_app: [Scrip.IAPReceipt.t()],
          original_application_version: String.t(),
          original_purchase_date: DateTime.t(),
          original_purchase_date_ms: Scrip.timestamp(),
          receipt_creation_date: DateTime.t(),
          receipt_creation_date_ms: Scrip.timestamp(),
          receipt_type: String.t(),
          request_date: DateTime.t(),
          request_date_ms: Scrip.timestamp(),
          version_external_identifier: integer
        }

  @doc """
  The `#{__MODULE__}` struct

  Refers to auto-renewable subscription renewals that are open or failed in the past.
  """
  defstruct [
    :adam_id,
    :app_item_id,
    :application_version,
    :bundle_id,
    :download_id,
    :in_app,
    :original_application_version,
    :original_purchase_date,
    :original_purchase_date_ms,
    :receipt_creation_date,
    :receipt_creation_date_ms,
    :receipt_type,
    :request_date,
    :request_date_ms,
    :version_external_identifier
  ]

  @spec new(response :: map) :: Scrip.Receipt.t()
  @doc """
  Converts response map to `%#{__MODULE__}` struct

  """
  def new(response) do
    request_date_ms = Scrip.Util.to_timestamp(response["request_date_ms"])
    receipt_creation_date_ms = Scrip.Util.to_timestamp(response["receipt_creation_date_ms"])
    original_purchase_date_ms = Scrip.Util.to_timestamp(response["original_purchase_date_ms"])

    %__MODULE__{
      adam_id: response["adam_id"],
      app_item_id: response["app_item_id"],
      application_version: response["application_version"],
      bundle_id: response["bundle_id"],
      download_id: response["download_id"],
      in_app: Enum.map(response["in_app"], &Scrip.IAPReceipt.new/1),
      original_application_version: response["original_application_version"],
      original_purchase_date: Scrip.Util.to_datetime(original_purchase_date_ms),
      original_purchase_date_ms: original_purchase_date_ms,
      receipt_creation_date: Scrip.Util.to_datetime(receipt_creation_date_ms),
      receipt_creation_date_ms: receipt_creation_date_ms,
      receipt_type: response["receipt_type"],
      request_date: Scrip.Util.to_datetime(request_date_ms),
      request_date_ms: request_date_ms,
      version_external_identifier: response["version_external_identifier"]
    }
  end
end
