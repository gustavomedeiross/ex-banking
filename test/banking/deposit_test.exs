defmodule Banking.FeaturesTest.Deposit do
  use Banking.DataCase

  alias Banking.Features.Deposit.{Command, Handler}
  alias Banking.Events.{BankAccountOpened, MoneyDeposited}

  @a_opened_account %BankAccountOpened{id: Ecto.UUID.generate(), initial_balance: 0}

  describe "Depositing money to a bank account" do
    test "The account should be open in order to deposit money" do
      command = build_command(%{amount: 50_00})
      assert {:error, :account_must_be_open} = Handler.handle([], command)
    end

    test "Customer can deposit a positive amount with a opened account" do
      {:ok, events} = Handler.handle([@a_opened_account], build_command(%{amount: 50_00}))
      assert [%MoneyDeposited{amount: 50_00}] = events
    end

    test "Customer can't deposit zero" do
      command = build_command(%{amount: 0_00})
      assert {:error, :the_deposited_amount_must_be_positive} = Handler.handle([@a_opened_account], command)
    end

    test "Customer can't deposit a negative value" do
      command = build_command(%{amount: -30_00})
      assert {:error, :the_deposited_amount_must_be_positive} = Handler.handle([@a_opened_account], command)
    end
  end

  defp build_command(%{} = data) do
    Command.changeset(%Command{}, data)
    |> Ecto.Changeset.apply_action!(:update)
  end
end
