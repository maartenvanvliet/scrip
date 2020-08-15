defmodule ScripTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "returns valid response", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, response("valid"))
    end)

    assert {:ok, %Scrip.Response{status: 0}} =
             Scrip.verify_receipt(receipt(),
               production_url: endpoint_url(bypass.port),
               password: "secret"
             )
  end

  test "errors with invalid password", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, response("21004"))
    end)

    assert {:error, %Scrip.Response.Error{status: 21_004}} =
             Scrip.verify_receipt(receipt(),
               production_url: endpoint_url(bypass.port),
               password: "bogus"
             )
  end

  test "errors with invalid receipt data", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, response("21002"))
    end)

    assert {:error, %Scrip.Response.Error{status: 21_002}} =
             Scrip.verify_receipt("bogus",
               production_url: endpoint_url(bypass.port),
               password: "bogus"
             )
  end

  test "errors with unknown error", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, Jason.encode!(%{status: 21_202}))
    end)

    assert {:error,
            %Scrip.Response.Error{status: 21_202, message: "Unknown status (21202) was returned"}} =
             Scrip.verify_receipt("bogus",
               production_url: endpoint_url(bypass.port),
               password: "bogus"
             )
  end

  test "retries on sandbox valid response", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/prod", fn conn ->
      Plug.Conn.resp(conn, 200, response("21007"))
    end)

    Bypass.expect_once(bypass, "POST", "/sandbox", fn conn ->
      Plug.Conn.resp(conn, 200, response("valid"))
    end)

    assert {:ok, %Scrip.Response{status: 0}} =
             Scrip.verify_receipt(receipt(),
               production_url: endpoint_url(bypass.port, "prod"),
               sandbox_url: endpoint_url(bypass.port, "sandbox"),
               password: "secret"
             )
  end

  test "errors on bad response code", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      Plug.Conn.resp(conn, 400, Jason.encode!(%{code: 400}))
    end)

    assert {:error, %Scrip.Error{status_code: 400, message: "{\"code\":400}"}} =
             Scrip.verify_receipt("bogus",
               production_url: endpoint_url(bypass.port),
               password: "bogus"
             )
  end

  test "errors on closed socket", %{bypass: bypass} do
    Bypass.down(bypass)

    assert {:error, %Scrip.Error{status_code: nil, message: :econnrefused}} =
             Scrip.verify_receipt("bogus",
               production_url: endpoint_url(bypass.port),
               password: "bogus"
             )

    Bypass.up(bypass)
  end

  def receipt do
    File.read!("test/support/fixtures/receipt")
  end

  def response(name) do
    File.read!("test/support/fixtures/#{name}.json")
  end

  defp endpoint_url(port, type \\ "prod") do
    "http://localhost:#{port}/#{type}"
  end
end
