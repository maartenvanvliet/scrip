defmodule Scrip.Util do
  @moduledoc false

  @spec to_boolean(String.t() | nil) :: boolean | nil
  def to_boolean(nil), do: nil
  def to_boolean("true"), do: true
  def to_boolean("1"), do: true
  def to_boolean("false"), do: false
  def to_boolean("0"), do: false

  @spec to_datetime(timestamp :: Scripp.timestamp() | nil) :: DateTime.t() | nil | no_return()
  def to_datetime(nil), do: nil
  def to_datetime(timestamp), do: DateTime.from_unix!(timestamp, :millisecond)

  @spec to_environment(String.t()) :: :sandbox | :production | nil
  def to_environment(nil), do: nil
  def to_environment("Production"), do: :production
  def to_environment("Sandbox"), do: :sandbox

  @spec to_timestamp(datetime_ms :: String.t() | nil) :: Scrip.timestamp() | nil
  def to_timestamp(nil), do: nil
  def to_timestamp(datetime_ms), do: String.to_integer(datetime_ms)
end
