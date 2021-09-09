defmodule Banking.Features.Withdraw.Command do
  use Ecto.Schema
  import Ecto.Changeset

  alias Banking.Features.Withdraw.Command

  @primary_key false
  embedded_schema do
    field :amount, :integer
  end

  def changeset(%Command{} = command, attrs) do
    %Command{}
    command
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
  end
end

defmodule Banking.Features.Withdraw.Handler do
  alias Banking.Projector
  alias Banking.Features.Withdraw.Command
  alias Banking.Events.MoneyWithdrawn

  def handle(events, %Command{} = command) do
    with :ok <- validate_account_is_open(events),
         :ok <- validate_amount(command),
         :ok <- validate_account_has_enough_funds(events, command) do
      events = 
        command
        |> Map.from_struct()
        |> MoneyWithdrawn.new()
        |> List.wrap()
      {:ok, events}
    end
  end

  defp validate_account_is_open(events) do
    account = Projector.project(events)
    if account.open do
      :ok
    else
      {:error, :account_must_be_open}
    end
  end

  defp validate_amount(command) do
    if command.amount > 0 do
      :ok
    else
      {:error, :cannot_withdraw_a_negative_amount}
    end
  end

  defp validate_account_has_enough_funds(events, command) do
    %{balance: balance} = Projector.project(events)
    if balance >= command.amount do
      :ok
    else
      {:error, :account_does_not_have_enough_funds}
    end
  end
end

defmodule Banking.Events.MoneyWithdrawn do
  use Ecto.Schema
  import Ecto.Changeset
  alias Banking.Events.MoneyWithdrawn

  @primary_key false
  embedded_schema do
    field :amount, :integer
  end

  def new(attrs) do
    %MoneyWithdrawn{}
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
    |> apply_action!(:update)
  end
end
