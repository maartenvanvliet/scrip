defmodule Scrip.Error do
  @type t :: %__MODULE__{
          status_code: integer,
          message: String.t()
        }
  defexception [:status_code, :message]
end
