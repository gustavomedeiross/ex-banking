defmodule Banking.FeaturesTest.Deposit do
  use Banking.DataCase

  alias Banking.Features.Deposit.{Command, Handler}
  alias Banking.Events.{BankAccountOpened, MoneyDeposited}

  describe "Depositing money to a bank account" do
    test "The account should be opened in order to deposit money" do
      command = 
        Command.changeset(%Command{}, %{amount: 50})
        |> Ecto.Changeset.apply_changes()

      assert {:error, :account_not_opened} = Handler.handle([], command)
    end

    test "User can deposit a positive amount with a opened account" do
      command = 
        Command.changeset(%Command{}, %{amount: 50_00})
        |> Ecto.Changeset.apply_changes()

      {:ok, events} = Handler.handle([
        %BankAccountOpened{id: Ecto.UUID.generate(), initial_balance: 0}
      ], command)
      assert [
        %MoneyDeposited{amount: 50_00}
      ] = events
    end
  end
end
