defmodule BankingWeb.OpenBankAccountController do
  use BankingWeb, :controller

  alias Banking.Accounts

  action_fallback BankingWeb.FallbackController

  def create(conn, params) do
    with :ok <- Accounts.open_bank_account(params) do
      send_resp(conn, 201, "")
    end
  end
end
