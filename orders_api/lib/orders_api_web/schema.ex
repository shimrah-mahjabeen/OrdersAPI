defmodule OrdersApiWeb.Schema do
  use Absinthe.Schema
  import_types(OrdersApiWeb.Schema.Types)

  query do
    @desc "Get an order by ID"
    field :order, type: :order do
      arg(:id, non_null(:id))
      resolve(&OrdersApi.Resolvers.Orders.get_order/3)
    end

    @desc "Get all orders for a customer email"
    field :orders_for_customer, list_of(:order) do
      arg(:email, non_null(:string))
      resolve(&OrdersApi.Resolvers.Orders.get_orders_for_customer/3)
    end
  end

  mutation do
    @desc "Create a new order"
    field :create_order, type: :order do
      arg(:customer_email, non_null(:string))
      arg(:original_value, non_null(:float))

      resolve(&OrdersApi.Resolvers.Orders.create_order/3)
    end

    @desc "Apply payment to an order"
    field :apply_payment_to_order, type: :order do
      arg(:order_id, non_null(:id))
      arg(:amount, non_null(:float))
      resolve(&OrdersApi.Resolvers.Orders.apply_payment_to_order/3)
    end

    @desc "Create a new order and pay"
    field :create_order_and_pay, type: :order do
      arg(:customer_email, non_null(:string))
      arg(:order_amount, non_null(:float))
      arg(:payment_amount, non_null(:float))

      resolve(&OrdersApi.Resolvers.Orders.create_order_and_pay/3)
    end
  end
end
