defmodule Banking.FeaturesTest.OpenBankAccount do
  use Banking.DataCase

  alias Banking.Features.OpenBankAccount.{Command, Handler}
  alias Banking.Events.BankAccountOpened

  describe "Opening a bank account" do
    test "User can open a bank account with a positive balance" do
      {:ok, events} = Handler.handle([], command(%{initial_balance: 50_00}))
      assert [
        %BankAccountOpened{id: _id, initial_balance: 50_00}
      ] = events
    end

    test "User can't open a bank account with a negative balance" do
      command = command(%{initial_balance: -30_00})
      assert {:error, :initial_balance_cannot_be_negative} = Handler.handle([], command)
    end

    test "User can open a bank account with zero balance" do
      command = command(%{initial_balance: 0})
      assert {:ok, [
        %BankAccountOpened{id: _id, initial_balance: 0}
      ]} = Handler.handle([], command)
    end

    test "Can't open an already open bank account" do
      command = command(%{initial_balance: 0_00})
      assert {:error, :account_is_already_open} = Handler.handle([
        %BankAccountOpened{id: command.id, initial_balance: 0_00}
      ], command)
    end
  end

  defp command(%{} = data) do
    Command.changeset(%Command{}, data)
    |> Ecto.Changeset.apply_action!(:update)
  end
end
