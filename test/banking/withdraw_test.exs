defmodule Banking.FeaturesTest.Withdraw do
  use Banking.DataCase

  alias Banking.Features.Withdraw.{Command, Handler}
  alias Banking.Events.{BankAccountOpened, MoneyDeposited, MoneyWithdrawn}

  describe "Withdrawing money from a bank account" do
    test "The account must be opened in order to withdraw money" do
      command = 
        Command.changeset(%Command{}, %{amount: 50})
        |> Ecto.Changeset.apply_changes()

      assert {:error, :account_not_opened} = Handler.handle([], command)
    end

    test "Customer can't withdraw a negative amount" do
      command = 
        Command.changeset(%Command{}, %{amount: -50_00})
        |> Ecto.Changeset.apply_changes()

      assert {:error, :cannot_withdraw_a_negative_amount} = Handler.handle([
        %BankAccountOpened{id: Ecto.UUID.generate(), initial_balance: 0},
      ], command)
    end

    test "Customer can't withdraw if there's not enough funds" do
      command = 
        Command.changeset(%Command{}, %{amount: 100_00})
        |> Ecto.Changeset.apply_changes()

      assert {:error, :account_does_not_have_enough_funds} = Handler.handle([
        %BankAccountOpened{id: Ecto.UUID.generate(), initial_balance: 0},
        %MoneyDeposited{amount: 50_00},
      ], command)
    end

    test "Customer can withdraw if there's enough funds" do
      command = 
        Command.changeset(%Command{}, %{amount: 100_00})
        |> Ecto.Changeset.apply_changes()

      {:ok, events} = Handler.handle([
        %BankAccountOpened{id: Ecto.UUID.generate(), initial_balance: 100_00},
        %MoneyDeposited{amount: 50_00},
      ], command)
      assert [
        %MoneyWithdrawn{amount: 100_00}
      ] = events
    end
  end
end
