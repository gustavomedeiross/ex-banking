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
  alias Banking.Features.Deposit.Command
  alias Banking.Events.{BankAccountOpened, MoneyDeposited}

  def handle(events, %Command{} = command) do
    account_was_opened = 
      events
      |> Enum.filter(&(match?(%BankAccountOpened{}, &1)))
      |> length() > 0

    if account_was_opened do
      events = 
        command
        |> Map.from_struct()
        |> MoneyDeposited.new()
        |> List.wrap()
      {:ok, events}
    else
      {:error, :account_not_opened}
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
