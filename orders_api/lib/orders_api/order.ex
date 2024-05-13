defmodule OrdersApi.Order do
  defstruct [:id, :customer_email, :original_value, :current_balance, payments: []]
end
