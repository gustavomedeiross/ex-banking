defmodule BankingWeb.WithdrawController do
  use BankingWeb, :controller

  alias Banking.Accounts

  action_fallback BankingWeb.FallbackController

  def create(conn, %{"id" => id} = params) do
    with :ok <- Accounts.withdraw(id, params) do
      send_resp(conn, 201, "")
    end
  end
end
