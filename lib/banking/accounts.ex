defmodule Banking.Accounts do
  alias Ecto.Changeset
  alias Banking.EventStoreDB
  alias Banking.Features.{OpenBankAccount, Deposit, Withdraw}

  def open_bank_account(attrs \\ %{}) do
    command = OpenBankAccount.Command.changeset(%OpenBankAccount.Command{}, attrs)
    if command.valid? do
      command = Changeset.apply_changes(command)
      EventStoreDB.stream!(command.id)
      |> parse_spear_events()
      |> Enum.to_list()
      |> OpenBankAccount.Handler.handle(command)
      |> case  do
        {:ok, events} -> 
          events
          |> prepare_events_to_store()
          |> EventStoreDB.append(command.id)
        error -> error
      end
    else
      {:error, command}
    end
  end

  def deposit(account_id, attrs \\ %{}) when is_binary(account_id) do
    command = Deposit.Command.changeset(%Deposit.Command{}, attrs)
    if command.valid? do
      command = Changeset.apply_changes(command)
      EventStoreDB.stream!(account_id)
      |> parse_spear_events()
      |> Enum.to_list()
      |> Deposit.Handler.handle(command)
      |> case  do
        {:ok, events} -> 
          events
          |> prepare_events_to_store()
          |> EventStoreDB.append(account_id)
        error -> error
      end
    else
      {:error, command}
    end
  end

  def withdraw(account_id, attrs \\ %{}) when is_binary(account_id) do
    command = Withdraw.Command.changeset(%Withdraw.Command{}, attrs)
    if command.valid? do
      command = Changeset.apply_changes(command)
      EventStoreDB.stream!(account_id)
      |> parse_spear_events()
      |> Enum.to_list()
      |> Withdraw.Handler.handle(command)
      |> case  do
        {:ok, events} -> 
          events
          |> prepare_events_to_store()
          |> EventStoreDB.append(account_id)
        error -> error
      end
    else
      {:error, command}
    end
  end


  defp parse_spear_events(events) do
    Enum.map(events, fn %Spear.Event{type: type, body: body} -> 
      type
      |> String.to_existing_atom()
      |> struct(atomize_map(body))
    end)
  end

  defp atomize_map(map) do
    for {key, val} <- map, 
      into: %{}, 
      do: {String.to_atom(key), val}
  end

  defp prepare_events_to_store(events) do
    Enum.map(events, fn event -> 
      event.__struct__
      |> Atom.to_string
      |> Spear.Event.new(Map.from_struct(event))
    end)
  end
end
