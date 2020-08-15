# Scrip

## [![Hex pm](http://img.shields.io/hexpm/v/scrip.svg?style=flat)](https://hex.pm/packages/scrip) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT) ![CI](https://github.com/maartenvanvliet/scrip/workflows/CI/badge.svg)

<!-- MDOC !-->

Scrip is a library to verify Apple App Store receipts. See the [Apple docs](https://developer.apple.com/documentation/appstorereceipts) for more information

## Installation

The package can be installed by adding `scrip` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:script, "~> 1.0.0"},
    {:jason, "~> 1.1"}, # optional
    {:httpoison, "~> 1.7"}, # optional
  ]
end
```

`Jason` and `HTTPoison` are optional and can be overriden with other implementations
but these are the default implementations. See `Scrip.Config` for more information.

## Usage

First set up In-App Purchases in App Store Connect. For your app should set the App-Specific Shared Secret, we can
use this later on to verify the receipt.

The usual flow is that your app does an in app purchase. This returns a Base64 receipt to the app. Your app can send the
receipt data to your backend to validate against the Apple servers.

The backend can verify the validity of this receipt using `Scrip.verify_receipt("BASE64_RECEIPT_DATA", password: "*App-Specific Shared Secret*")`

If all goes well, it returns an `:ok` tuple with the IAP information you can store on your backend.
Otherwise an `:error` tuple is returned.

See `Scrip.verify_receipt/3` for more information
