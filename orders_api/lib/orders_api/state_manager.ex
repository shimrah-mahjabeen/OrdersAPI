defmodule OrdersApi.StateManager do
  alias OrdersApi.Order
  alias OrdersApi.Payment

  use Agent
  require Logger

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def create_order(email, value) do
    id = :erlang.unique_integer([:positive])

    order = %Order{
      id: id,
      customer_email: email,
      original_value: value,
      current_balance: value,
      payments: []
    }

    Agent.update(__MODULE__, fn state -> Map.put(state, id, order) end)
    {:ok, order}
  end

  def create_order_and_pay(email, order_amount, payment_amount) do
    id = :erlang.unique_integer([:positive])
    pid = :erlang.unique_integer([:positive])

    order = %Order{
      id: id,
      customer_email: email,
      original_value: order_amount,
      current_balance: order_amount,
      payments: []
    }

    payment_status =  OrdersApi.GoblinPay.capture_payment()

    if payment_status == :failure do
        {:error, "Payment Failed - Transaction Cancelled"}
    else
        payment = %Payment{id: pid, order_id: id, amount: payment_amount}
        updated_order = %Order{
            order |
            payments: [payment | order.payments],
            current_balance: order.current_balance - payment_amount
          }

        Agent.update(__MODULE__, fn state -> Map.put(state, id, updated_order) end)
        {:ok, updated_order}
    end
  end

  def get_order(id) do
    case Integer.parse(id) do
      {id, ""} ->
        case Agent.get(__MODULE__, &Map.get(&1, id)) do
          nil -> {:error, "Order Not found"}
          order -> {:ok, order}
        end

      _ ->
        {:error, "Invalid Order ID format"}
    end
  end

  def get_orders_for_customer(email) do
    {:ok,
     Agent.get(__MODULE__, fn state ->
       state
       |> Map.values()
       |> Enum.filter(&(&1.customer_email == email))
     end)}
  end

  def apply_payment(order_id, amount) do
    case Integer.parse(order_id) do
      {id, ""} ->
        Agent.get_and_update(__MODULE__, fn state ->
          case Map.get(state, id) do
            nil ->
              {{:error, "Order not found"}, state}

            order ->
              if order.current_balance >= amount do
                pid = :erlang.unique_integer([:positive])
                payment = %Payment{id: pid, order_id: id, amount: amount}
                new_balance = order.current_balance - amount
                updated_order = %{order | current_balance: new_balance, payments: [payment | order.payments]}
                new_state = Map.put(state, id, updated_order)
                {{:ok, updated_order}, new_state}
              else
                {{:error, "Limited Exceeded"}, state}
              end
          end
        end)

      _ ->
        {:error, "Invalid Order ID format"}
    end
  end
end
