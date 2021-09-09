defmodule Banking.Features.Deposit.Command do
  use Ecto.Schema
  import Ecto.Changeset

  alias Banking.Features.Deposit.Command

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


defmodule Banking.Features.Deposit.Handler do
  alias Banking.Projector
  alias Banking.Features.Deposit.Command
  alias Banking.Events.MoneyDeposited

  def handle(events, %Command{} = command) do
    with :ok <- validate_account_is_open(events),
         :ok <- validate_amount(command) do
      events = 
        command
        |> Map.from_struct()
        |> MoneyDeposited.new()
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
      {:error, :the_deposited_amount_must_be_positive}
    end
  end
end

defmodule Banking.Events.MoneyDeposited do
  use Ecto.Schema
  import Ecto.Changeset
  alias Banking.Events.MoneyDeposited

  @primary_key false
  embedded_schema do
    field :amount, :integer
  end

  def new(attrs) do
    %MoneyDeposited{}
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
    |> apply_action!(:update)
  end
end
