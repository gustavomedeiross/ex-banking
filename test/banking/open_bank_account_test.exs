defmodule Banking.FeaturesTest.OpenBankAccount do
  use Banking.DataCase

  alias Banking.Features.OpenBankAccount.{Command, Handler}
  alias Banking.Events.BankAccountOpened

  describe "Opening a bank account" do
    test "User can open a bank account with a positive balance" do
      command = 
        Command.changeset(%Command{}, %{initial_balance: 50_00})
        |> Ecto.Changeset.apply_changes()

      assert {:ok, [
        %BankAccountOpened{id: _id, initial_balance: 50_00}
      ]} = Handler.handle([], command)
    end

    test "User can't open a bank account with a negative balance" do
      command = 
        Command.changeset(%Command{}, %{initial_balance: -30_00})
        |> Ecto.Changeset.apply_changes()

      assert {:error, :initial_balance_cannot_be_negative} = Handler.handle([], command)
    end

    test "User can open a bank account with zero balance" do
      command = 
        Command.changeset(%Command{}, %{initial_balance: 0})
        |> Ecto.Changeset.apply_changes()

      assert {:ok, [
        %BankAccountOpened{id: _id, initial_balance: 0}
      ]} = Handler.handle([], command)
    end
  end
end
