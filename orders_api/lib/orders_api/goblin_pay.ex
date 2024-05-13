defmodule OrdersApi.GoblinPay do
  def capture_payment() do
    [:success, :success, :success, :failure] |> Enum.shuffle() |> hd()
  end
end
