defmodule Scrip do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @typedoc """
  The Base64 encoded receipt data.
  """
  @type receipt_data :: String.t()

  @typedoc """
  UNIX epoch time format, in milliseconds.
  """
  @type timestamp :: integer

  @spec verify_receipt(
          receipt_data,
          Scrip.Response.environment() | [Scrip.Config.opts()],
          [Scrip.Config.opts()] | Scrip.Config.t()
        ) ::
          {:ok, Scrip.Response.t()}
          | {:error, Scrip.Response.Error.t()}
          | {:error, Scrip.Error.t()}

  @doc """
  Call `verify_receipt/3` with the Base64 receipt and a valid password to verify the App Store receipts.

  ## Examples

      > Scrip.verify_receipt("BASE64_DATA", password: "secret")
      {:ok, %Scrip.Response{status: 0}}


  You can explicitly specify the environment. It defaults to `:production`,
  and will retry on the `:sandbox` environment. See [Apple docs](https://developer.apple.com/documentation/storekit/in-app_purchase/validating_receipts_with_the_app_store#//apple_ref/doc/uid/TP40010573-CH104-SW1)

      > Scrip.verify_receipt("BASE64_DATA", :sandbox, password: "secret")

  Returns an error tuple when something went wrong:

      > Scrip.verify_receipt("BASE64_DATA", password: "wrong password")
      {:error, %Scrip.Response{}}
  """
  def verify_receipt(receipt_data, mode \\ :production, opts \\ [])

  def verify_receipt(receipt_data, mode, _opts) when is_list(mode) do
    config = Scrip.Config.new(mode)

    verify_receipt(receipt_data, :production, config)
  end

  def verify_receipt(receipt_data, mode, opts) when is_list(opts) and is_atom(mode) do
    config = Scrip.Config.new(opts)

    verify_receipt(receipt_data, mode, config)
  end

  def verify_receipt(receipt_data, mode, %Scrip.Config{} = config) when is_atom(mode) do
    request_body = prepare_request_body(receipt_data, config)
    headers = [{"Content-Type", "application/json"}]

    case config.client.post(url(mode, config), request_body, headers, config.request_opts) do
      {:ok, 200, _, body} ->
        config.json_encoder.decode!(body)
        |> build_response
        |> handle_response(receipt_data, config)

      {:ok, status_code, _, body} ->
        {:error, %Scrip.Error{status_code: status_code, message: body}}

      {:error, error} ->
        {:error, %Scrip.Error{message: error}}
    end
  end

  defp url(:production, config) do
    config.production_url
  end

  defp url(:sandbox, config) do
    config.sandbox_url
  end

  defp handle_response(%Scrip.Response{} = response, _receipt_data, _config) do
    {:ok, response}
  end

  # Retry on sandbox url
  #
  # Verify your receipt first with the production URL; then verify with the
  # sandbox URL if you receive a 21007 status code. This approach ensures
  # you do not have to switch between URLs while your application is tested,
  # reviewed by App Review, or live in the App Store.
  # See: https://developer.apple.com/documentation/storekit/in-app_purchase/validating_receipts_with_the_app_store#//apple_ref/doc/uid/TP40010573-CH104-SW1
  defp handle_response(%Scrip.Response.Error{status: 21_007}, receipt_data, config) do
    verify_receipt(receipt_data, :sandbox, config)
  end

  defp handle_response(%Scrip.Response.Error{} = response, _receipt_data, _config) do
    {:error, response}
  end

  defp build_response(response) do
    Scrip.Response.new(response)
  end

  defp prepare_request_body(receipt_data, config) do
    %{"receipt-data" => receipt_data, "password" => config.password}
    |> config.json_encoder.encode!()
  end
end
