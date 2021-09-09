defmodule Banking.Account do
  @type t :: %__MODULE__{
    balance: Integer.t(),
    open: boolean(),
  }
  @enforce_keys [:balance, :open]
  defstruct [:balance, :open]
end

defmodule Banking.Projector do
  alias Banking.{Account, Projector}
  alias Banking.Events.{BankAccountOpened, MoneyDeposited, MoneyWithdrawn}

  @initial_state %Account{balance: 0, open: false}

  def project(events) when is_list(events) do
    Enum.reduce(events, @initial_state, fn event, account -> 
      Projector.handle(account, event)
    end)
  end

  def handle(%Account{}, %BankAccountOpened{} = event) do
    %Account{balance: event.initial_balance, open: true}
  end

  def handle(%Account{balance: balance} = account, %MoneyDeposited{} = event) do
    %Account{account | balance: balance + event.amount}
  end

  def handle(%Account{balance: balance} = account, %MoneyWithdrawn{} = event) do
    %Account{account | balance: balance - event.amount}
  end
end
