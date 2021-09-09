defmodule Banking.Account do
  @type t :: %__MODULE__{
    balance: Integer.t(),
  }
  @enforce_keys [:balance]
  defstruct [:balance]
end

defmodule Banking.Projector do
  alias Banking.{Account, Projector}
  alias Banking.Events.{BankAccountOpened, MoneyDeposited, MoneyWithdrawn}

  @initial_state %Account{balance: 0}

  def project(events) when is_list(events) do
    Enum.reduce(events, @initial_state, fn event, account -> 
      Projector.handle(account, event)
    end)
  end

  def handle(%Account{}, %BankAccountOpened{} = event) do
    %Account{balance: event.initial_balance}
  end

  def handle(%Account{balance: balance}, %MoneyDeposited{} = event) do
    %Account{balance: balance + event.amount}
  end

  def handle(%Account{balance: balance}, %MoneyWithdrawn{} = event) do
    %Account{balance: balance - event.amount}
  end
end
