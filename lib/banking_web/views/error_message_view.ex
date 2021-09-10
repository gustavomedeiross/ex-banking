defmodule BankingWeb.ErrorMessageView do
  use BankingWeb, :view

  def render("error.json", %{message: message}) do
    %{message: message}
  end
end

