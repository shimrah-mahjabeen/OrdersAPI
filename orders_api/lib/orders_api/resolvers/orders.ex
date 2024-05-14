defmodule OrdersApi.Resolvers.Orders do
  alias OrdersApi.StateManager
  require Logger
  require Regex
  def create_order(_root, %{customer_email: email, original_value: value}, _info) do
    try do
      if Regex.match?(~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/, email) do
        case StateManager.create_order(email, value) do
          {:ok, updated_order} -> {:ok, updated_order}
          {:error, message} -> {:error, message}
         end
      else
        {:error, "Invalid Email"}
      end

    rescue
      error in RuntimeError -> {:error, error}
    end
  end

  def create_order_and_pay(_root, %{customer_email: email, order_amount: order_amount, payment_amount: payment_amont}, _info) do
    try do
      if Regex.match?(~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/, email) do
        case StateManager.create_order_and_pay(email, order_amount, payment_amont) do
          {:ok, updated_order} -> {:ok, updated_order}
          {:error, message} -> {:error, message}
         end
      else
        {:error, "Invalid Email"}
      end

    rescue
      error in RuntimeError -> {:error, error}
    end
  end

  def get_order(_root, %{id: id}, _info) do
    try do
      case StateManager.get_order(id) do
       {:ok, order} -> {:ok, order}
       {:error, message} -> {:error, message}
      end
    catch
      error -> {:error, error}
    end
  end

  def get_orders_for_customer(_root, %{email: email}, _info) do
    try do
      if Regex.match?(~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/, email) do
        case StateManager.get_orders_for_customer(email) do
          {:ok, orders} -> {:ok, orders}
          {:error, message} -> {:error, message}
         end
      else
        {:error, "Invalid Email"}
      end

    rescue
      error in RuntimeError -> {:error, error}
    end
  end

  def apply_payment_to_order(_root, %{order_id: order_id, amount: amount}, _info) do
    try do
      case StateManager.apply_payment(order_id, amount) do
       {:ok, updated_order} -> {:ok, updated_order}
       {:error, message} -> {:error, message}
      end
    catch
      error -> {:error, error}
    end
  end

end
