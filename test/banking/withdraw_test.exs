defmodule Banking.FeaturesTest.Withdraw do
  use Banking.DataCase

  alias Banking.Features.Withdraw.{Command, Handler}
  alias Banking.Events.{BankAccountOpened, MoneyDeposited, MoneyWithdrawn}

  @id Ecto.UUID.generate()

  describe "Withdrawing money from a bank account" do
    test "The account must be opened in order to withdraw money" do
      command = build_command(%{amount: 50_00})
      assert {:error, :account_must_be_open} = Handler.handle([], command)
    end

    test "Customer can't withdraw a negative amount" do
      command = build_command(%{amount: -50_00})
      assert {:error, :cannot_withdraw_a_negative_amount} = Handler.handle([
        %BankAccountOpened{id: @id, initial_balance: 0}
      ], command)
    end

    test "Customer can't withdraw if there's not enough funds" do
      command = build_command(%{amount: 100_00})
      assert {:error, :account_does_not_have_enough_funds} = Handler.handle([
        %BankAccountOpened{id: @id, initial_balance: 0},
        %MoneyDeposited{amount: 50_00},
      ], command)
    end

    test "Customer can withdraw if there's enough funds" do
      command = build_command(%{amount: 100_00})
      {:ok, events} = Handler.handle([
        %BankAccountOpened{id: @id, initial_balance: 0},
        %MoneyDeposited{amount: 150_00},
      ], command)
      assert [%MoneyWithdrawn{amount: 100_00}] = events
    end

    test "Can withdraw after multiple deposits" do
      command = build_command(%{amount: 400_00})
      {:ok, events} = Handler.handle([
        %BankAccountOpened{id: @id, initial_balance: 100_00},
        %MoneyDeposited{amount: 100_00},
        %MoneyDeposited{amount: 200_00},
      ], command)
      assert [%MoneyWithdrawn{amount: 400_00}] = events
    end

    test "Can perform two withdraws" do
      {:ok, events} = Handler.handle([
        %BankAccountOpened{id: @id, initial_balance: 0},
        %MoneyDeposited{amount: 100_00},
        %MoneyWithdrawn{amount: 50_00},
        %MoneyDeposited{amount: 50_00},
      ], build_command(%{amount: 100_00}))
      assert [%MoneyWithdrawn{amount: 100_00}] = events
    end

    test "Can't perform two withdraws if there's not the required amount on the second one" do
      result = Handler.handle([
        %BankAccountOpened{id: @id, initial_balance: 0},
        %MoneyDeposited{amount: 100_00},
        %MoneyWithdrawn{amount: 50_00},
        %MoneyWithdrawn{amount: 20_00},
      ], build_command(%{amount: 50_00}))
      assert {:error, :account_does_not_have_enough_funds} = result
    end
  end

  defp build_command(%{} = data) do
    Command.changeset(%Command{}, data)
    |> Ecto.Changeset.apply_action!(:update)
  end
end
