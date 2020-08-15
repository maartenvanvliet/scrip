defmodule Scrip.IAPReceipt do
  @moduledoc """
  Contains the in-app purchase receipt fields for all in-app purchase transactions.

  See: https://developer.apple.com/documentation/appstorereceipts/responsebody/receipt/in_app
  """
  @typedoc """
  An indicator of whether an auto-renewable subscription is in the introductory price period.

  #### Possible values

  `true`
  The customer’s subscription is in an introductory price period

  `false`
  The subscription is not in an introductory price period.
  """
  @type is_in_intro_offer_period :: boolean() | nil

  @typedoc """
  An indicator of whether an auto-renewable subscription is in the free trial period.

  #### Possible Values

  `true`
  The subscription is in the free trial period.

  `false`
  The subscription is not in the free trial period.
  """
  @type is_trial_period :: boolean()

  @typedoc """
  Contains the in-app purchase receipt fields for all in-app purchase transactions.

  See: https://developer.apple.com/documentation/appstorereceipts/responsebody/receipt/in_app
  """
  @type t :: %__MODULE__{
          expires_date: DateTime.t(),
          expires_date_ms: Scrip.timestamp(),
          is_in_intro_offer_period: is_in_intro_offer_period,
          is_trial_period: is_trial_period,
          original_purchase_date: DateTime.t(),
          original_purchase_date_ms: Scrip.timestamp(),
          original_transaction_id: String.t(),
          product_id: String.t(),
          purchase_date: DateTime.t(),
          purchase_date_ms: Scrip.timestamp(),
          quantity: String.t(),
          subscription_group_identifier: String.t(),
          transaction_id: String.t(),
          web_order_line_item_id: String.t()
        }

  @doc """
  The `#{__MODULE__}` struct

  Contains the in-app purchase receipt fields for all in-app purchase transactions.
  """
  defstruct [
    :expires_date,
    :expires_date_ms,
    :is_in_intro_offer_period,
    :is_trial_period,
    :original_purchase_date,
    :original_purchase_date_ms,
    :original_transaction_id,
    :product_id,
    :purchase_date,
    :purchase_date_ms,
    :quantity,
    :subscription_group_identifier,
    :transaction_id,
    :web_order_line_item_id
  ]

  @spec new(response :: map) :: Scrip.IAPReceipt.t()
  @doc """
  Converts response map to `%#{__MODULE__}` struct

  """
  def new(response) do
    expires_date_ms = Scrip.Util.to_timestamp(response["expires_date_ms"])
    original_purchase_date_ms = Scrip.Util.to_timestamp(response["original_purchase_date_ms"])
    purchase_date_ms = Scrip.Util.to_timestamp(response["purchase_date_ms"])

    %__MODULE__{
      expires_date: Scrip.Util.to_datetime(expires_date_ms),
      expires_date_ms: expires_date_ms,
      is_in_intro_offer_period: Scrip.Util.to_boolean(response["is_in_intro_offer_period"]),
      is_trial_period: Scrip.Util.to_boolean(response["is_trial_period"]),
      original_purchase_date: Scrip.Util.to_datetime(original_purchase_date_ms),
      original_purchase_date_ms: original_purchase_date_ms,
      original_transaction_id: response["original_transaction_id"],
      product_id: response["product_id"],
      purchase_date: Scrip.Util.to_datetime(purchase_date_ms),
      purchase_date_ms: purchase_date_ms,
      quantity: response["quantity"],
      subscription_group_identifier: response["subscription_group_identifier"],
      transaction_id: response["transaction_id"],
      web_order_line_item_id: response["web_order_line_item_id"]
    }
  end
end
