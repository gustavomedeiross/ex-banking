defmodule Banking.Features.OpenBankAccount.Command do
  use Ecto.Schema
  import Ecto.Changeset

  alias Banking.Features.OpenBankAccount.Command

  @primary_key false
  embedded_schema do
    field :id, :binary_id
    field :initial_balance, :integer
  end

  def changeset(%Command{} = command, attrs) do
    command
    |> cast(attrs, [:initial_balance])
    |> validate_required([:initial_balance])
    |> put_change(:id, Ecto.UUID.generate())
  end
end


defmodule Banking.Features.OpenBankAccount.Handler do
  alias Banking.Features.OpenBankAccount.Command
  alias Banking.Events.BankAccountOpened

  def handle(_events, %Command{} = command) do
    if command.initial_balance >= 0 do
      events = command
      |> Map.from_struct()
      |> BankAccountOpened.new()
      |> List.wrap()

      {:ok, events}
    else
      {:error, :initial_balance_cannot_be_negative}
    end
  end
end

defmodule Banking.Events.BankAccountOpened do
  use Ecto.Schema
  import Ecto.Changeset
  alias Banking.Events.BankAccountOpened

  @primary_key false
  embedded_schema do
    field :id, :binary_id
    field :initial_balance, :integer
  end

  def new(attrs) do
    %BankAccountOpened{}
    |> cast(attrs, [:id, :initial_balance])
    |> validate_required([:id, :initial_balance])
    |> apply_action!(:update)
  end
end
