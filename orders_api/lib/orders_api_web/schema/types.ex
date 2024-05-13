defmodule OrdersApiWeb.Schema.Types do
  use Absinthe.Schema.Notation

  object :order do
    field :id, :id
    field :customer_email, :string
    field :original_value, :float
    field :current_balance, :float
    field :payments, list_of(:payment)
  end

  object :payment do
    field :id, :id
    field :order_id, :id
    field :amount, :float
  end
end
