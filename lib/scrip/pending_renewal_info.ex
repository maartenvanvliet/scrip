defmodule Scrip.PendingRenewalInfo do
  @moduledoc """
  An array of elements that refers to auto-renewable subscription renewals that are open or failed in the past.

  Only returned for app receipts that contain auto-renewable subscriptions.

  See
  https://developer.apple.com/documentation/appstorereceipts/responsebody/pending_renewal_info
  """

  @typedoc """
  The renewal status for the auto-renewable subscription.

  #### Possible Values

  `true`
  The subscription will renew at the end of the current subscription period.

  `false`
  The customer has turned off automatic renewal for the subscription.

  See: https://developer.apple.com/documentation/appstorereceipts/auto_renew_status
  """
  @type auto_renew_status :: boolean()

  @typedoc """
  An indicator of whether an auto-renewable subscription is in the billing retry period.

  #### Possible Values

  `true`
  The App Store is attempting to renew the subscription.

  `false`
  The App Store has stopped attempting to renew the subscription.

  See: https://developer.apple.com/documentation/appstorereceipts/is_in_billing_retry_period
  """
  @type is_in_billing_retry_period :: boolean()

  @typedoc """
  Refers to auto-renewable subscription renewals that are open or failed in the past.

  See: https://developer.apple.com/documentation/appstorereceipts/responsebody/pending_renewal_info#properties
  """
  @type t :: %__MODULE__{
          auto_renew_product_id: String.t(),
          auto_renew_status: auto_renew_status,
          expiration_intent: 1..5,
          is_in_billing_retry_period: is_in_billing_retry_period,
          original_transaction_id: String.t(),
          product_id: String.t()
        }

  @doc """
  The `#{__MODULE__}` struct

  Contains the auto-renewable subscription renewals that are open or failed in the past.
  """
  defstruct [
    :auto_renew_product_id,
    :auto_renew_status,
    :expiration_intent,
    :is_in_billing_retry_period,
    :original_transaction_id,
    :product_id
  ]

  @spec new(response :: map) :: Scrip.PendingRenewalInfo.t()
  @doc """
  Converts response map to `%#{__MODULE__}` struct

  """
  def new(response) do
    %__MODULE__{
      auto_renew_product_id: response["auto_renew_product_id"],
      auto_renew_status: Scrip.Util.to_boolean(response["auto_renew_status"]),
      expiration_intent: String.to_integer(response["expiration_intent"]),
      is_in_billing_retry_period: Scrip.Util.to_boolean(response["is_in_billing_retry_period"]),
      original_transaction_id: response["original_transaction_id"],
      product_id: response["product_id"]
    }
  end
end
