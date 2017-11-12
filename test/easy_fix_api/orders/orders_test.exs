defmodule EasyFixApi.OrdersTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.{Orders, CustomerOrders}
  alias EasyFixApi.Orders.OrderStateMachine

  describe "diagnosis" do
    alias EasyFixApi.Orders.{Diagnosis}
    @invalid_diagnosis_attrs %{accepts_used_parts: nil, comment: nil, need_tow_truck: nil, state: nil}

    test "list_diagnosis/1 returns all diagnosis" do
      diagnosis = insert(:diagnosis)
      [listed_diag] = Orders.list_diagnosis()
      assert listed_diag.id == diagnosis.id
    end

    test "create_diagnosis/1 with valid data creates a diagnosis" do
      vehicle = insert(:vehicle_with_model)
      diagnosis_attrs = diagnosis_with_diagnosis_parts_params(vehicle.id)

      assert {:ok, %Diagnosis{} = diagnosis} = Orders.create_diagnosis(diagnosis_attrs)
      assert diagnosis.accepts_used_parts == true
      assert diagnosis.comment == "some comment"
      assert diagnosis.need_tow_truck == true
      # assert diagnosis.state == "some state"
      assert length(diagnosis.parts) == 2
      assert diagnosis.vehicle.id == diagnosis_attrs[:vehicle_id]
    end

    test "create_diagnosis/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_diagnosis(@invalid_diagnosis_attrs)
    end
  end

  describe "diagnosis_parts" do
    alias EasyFixApi.Orders.{DiagnosisPart}

    test "create_diagnosis_part/2 with valid data creates a diagnosis_part" do
      diagnosis = insert(:diagnosis)
      part = insert(:part)
      diagnosis_part_attrs =
        params_for(:diagnosis_part)
        |> put_in([:part_id], part.id)

      {:ok, %DiagnosisPart{} = diagnosis_part} = Orders.create_diagnosis_part(diagnosis_part_attrs, diagnosis.id)
      assert diagnosis_part.diagnosis.id == diagnosis.id
      assert diagnosis_part.part.id == part.id
      assert diagnosis_part.quantity == diagnosis_part_attrs[:quantity]
    end
    test "create_diagnosis_part/2 with comments on parts" do
      diagnosis = insert(:diagnosis)
      part = insert(:part)
      diagnosis_part_attrs =
        params_for(:diagnosis_part)
        |> put_in([:part_id], part.id)
        |> put_in([:comment], "some comment")

      {:ok, %DiagnosisPart{} = diagnosis_part} = Orders.create_diagnosis_part(diagnosis_part_attrs, diagnosis.id)
      assert diagnosis_part.diagnosis.id == diagnosis.id
      assert diagnosis_part.comment == "some comment"
    end
  end

  describe "quotes_parts" do
    alias EasyFixApi.Orders.{QuotePart}

    test "create_quote_part/2 with valid data creates a quote_part" do
      quote = insert(:quote)
      part = insert(:part)
      quote_part_attrs =
        params_for(:quote_part)
        |> put_in([:part_id], part.id)

      {:ok, %QuotePart{} = quote_part} = Orders.create_quote_part(quote_part_attrs, quote.id)
      assert quote_part.quote.id == quote.id
      assert quote_part.part.id == part.id
      assert quote_part.price.amount == quote_part_attrs[:price]
      assert quote_part.quantity == quote_part_attrs[:quantity]
    end

    test "update_quote_part/2 updates non-assoc fields" do
      quote = insert(:quote)
      part = insert(:part)
      quote_part_attrs =
        params_for(:quote_part)
        |> put_in([:part_id], part.id)
      {:ok, %QuotePart{} = quote_part} = Orders.create_quote_part(quote_part_attrs, quote.id)

      update_attrs = %{quantity: 2, price: 5000}
      {:ok, updated_quote_part} = Orders.update_quote_part(quote_part, update_attrs)
      assert updated_quote_part.quote.id == quote.id
      assert updated_quote_part.part.id == part.id
      assert updated_quote_part.price.amount == update_attrs[:price]
      assert updated_quote_part.quantity == update_attrs[:quantity]
    end

    test "update_quote_part/2 updates assoc fields" do
      quote = insert(:quote)
      part = insert(:part)
      quote_part_attrs =
        params_for(:quote_part)
        |> put_in([:part_id], part.id)
      {:ok, %QuotePart{} = quote_part} = Orders.create_quote_part(quote_part_attrs, quote.id)

      new_part = insert(:part)
      update_attrs = %{quantity: 2, price: 5000, part_id: new_part.id}
      {:ok, updated_quote_part} = Orders.update_quote_part(quote_part, update_attrs)
      assert updated_quote_part.quote.id == quote.id
      assert updated_quote_part.part.id == new_part.id
      assert updated_quote_part.price.amount == update_attrs[:price]
      assert updated_quote_part.quantity == update_attrs[:quantity]
    end
  end

  describe "quotes" do
    alias EasyFixApi.Orders.{Quote}

    test "create_quote/1 with valid data creates a quote" do
      garage = insert(:garage)
      diagnosis = insert(:diagnosis)
      %{part: part1} = diagnosis_parts_with_diagnosis(diagnosis) |> insert()
      %{part: part2} = diagnosis_parts_with_diagnosis(diagnosis) |> insert()
      parts = [
        %{part_id: part1.id, price: 4200, quantity: 1},
        %{part_id: part2.id, price: 200, quantity: 4},
      ]

      quote_attrs =
        params_for(:quote)
        |> put_in([:parts], parts)
        |> put_in([:diagnosis_id], diagnosis.id)
        |> put_in([:issuer_id], garage.id)
        |> put_in([:issuer_type], "garage")

      assert {:ok, %Quote{} = quote} = Orders.create_quote(quote_attrs)

      assert quote.service_cost.amount == quote_attrs[:service_cost]
      assert length(quote.quotes_parts) == 2
      assert quote.diagnosis.id == diagnosis.id
      assert quote.issuer.id == garage.user.id
      assert quote.issuer_type == :garage
    end

    test "update_quote_parts" do
      {quote_attrs, _garage, _order} = quote_with_all_params()
      assert {:ok, quote} = Orders.create_quote(quote_attrs)

      [part1, _part2] = quote_attrs[:parts]
      part1 =
        part1
        |> put_in([:part_id], insert(:part).id)
        |> put_in([:price], 123)

      update_quote_attrs =
        quote_attrs
        |> put_in([:parts], [part1])
        |> put_in([:service_cost], 144)

      {:ok, updated_quote} = Orders.update_quote(quote, update_quote_attrs)
      assert updated_quote.service_cost.amount == update_quote_attrs[:service_cost]
      assert length(updated_quote.quotes_parts) == 1
    end

    test "list_quotes_by_order" do
      {quote_attrs, _garage, order} = quote_with_all_params()
      assert {:ok, quote} = Orders.create_quote(quote_attrs)

      [a_quote] = Orders.list_quotes_by_order(order.id)
      assert a_quote.id == quote.id
      assert [] == Orders.list_quotes_by_order(0)
    end

    test "get_quote_for_garage_order" do
      {quote_attrs, garage, order} = quote_with_all_params()
      assert {:ok, quote} = Orders.create_quote(quote_attrs)

      {:ok, the_quote} = Orders.get_quote_for_garage_order(garage.id, order.id)
      assert the_quote.id == quote.id
      assert {:error, _} = Orders.get_quote_for_garage_order(0, order.id)
      assert {:error, _} = Orders.get_quote_for_garage_order(garage.id, 0)
    end

    test "put_quote_total_amount" do
      {quote_attrs, _garage, _order} = quote_with_all_params()
      assert {:ok, quote} = Orders.create_quote(quote_attrs)
      
      quote_total_amount = Orders.calculate_total_amount(quote)

      [bpart1, bpart2] = quote.quotes_parts
      total_amount =
        quote.service_cost
        |> Money.add(Money.multiply(bpart1.price, bpart1.quantity))
        |> Money.add(Money.multiply(bpart2.price, bpart2.quantity))

      assert total_amount == quote_total_amount
    end

    @max_amount Application.get_env(:easy_fix_api, :fees)[:customer_fee_on_quote_by_garage][:max_amount]
    @percent_fee Application.get_env(:easy_fix_api, :fees)[:customer_fee_on_quote_by_garage][:percent_fee]
    test "calculate_customer_percent_fee" do
      assert 0.0875 == CustomerOrders.calculate_customer_percent_fee(Money.new(800_00), Money.new(@max_amount), @percent_fee)
      assert 0.05 == CustomerOrders.calculate_customer_percent_fee(Money.new(1400_00), Money.new(@max_amount), @percent_fee)
    end

    test "will add customer @percent_fee to quote" do
      quote =
        build(:quote)
        |> with_service_cost(100_00)
        |> with_quotes_parts_price(100_00)
        |> with_total_amount(300_00)
      assert quote.total_amount == Orders.calculate_total_amount(quote)

      customer_quote = CustomerOrders.add_customer_fee(quote)
      whole_percent_fee = 1 + @percent_fee
      assert Money.multiply(quote.total_amount, whole_percent_fee) == customer_quote.total_amount
    end

    test "will add at most @max_amount customer fee to quote" do
      quote =
        build(:quote)
        |> with_service_cost(1000_00)
        |> with_quotes_parts_price(200_00)
        |> with_total_amount(1400_00)
      assert quote.total_amount == Orders.calculate_total_amount(quote)

      customer_quote = CustomerOrders.add_customer_fee(quote)
      assert Money.add(quote.total_amount, Money.new(@max_amount)) == customer_quote.total_amount
    end
  end

  describe "orders" do
    alias EasyFixApi.Orders.Order

    @invalid_attrs %{conclusion_date: nil, opening_date: nil, state: nil, sub_state: nil}

    test "list_orders/0 returns all orders" do
      order = insert(:order)
      [listed_order] = Orders.list_orders()
      assert listed_order.id == order.id
    end

    test "create_order_with_diagnosis/1 with valid data creates a order" do
      customer = insert(:customer)
      [vehicle] = customer.vehicles
      order_attrs = order_with_all_params(customer.id, vehicle.id)

      assert {:ok, %Order{} = order} = Orders.create_order_with_diagnosis(order_attrs)

      assert order.state == :created_with_diagnosis
      assert order.customer.id == order_attrs[:customer_id]
    end

    test "set_order_quoted_by_garages/1 changes its state to :quoted_by_garages" do
      customer = insert(:customer)
      [vehicle] = customer.vehicles
      order_attrs = order_with_all_params(customer.id, vehicle.id)
      {:ok, order} = Orders.create_order_with_diagnosis(order_attrs)

      next_state_attrs = %{
        state: :quoted_by_garages,
        state_due_date: OrderStateMachine.calculate_state_due_date(:quoted_by_garages)
      }
      assert {:ok, order} = Orders.update_order_state(order, next_state_attrs)
      assert order.state == :quoted_by_garages
      assert Timex.compare(Timex.now, order.state_due_date) == -1
    end

    test "create_order_with_diagnosis/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order_with_diagnosis(@invalid_attrs)
    end

    test "delete_order/1 deletes the order" do
      order = insert(:order)
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "delete_order/1 deletes the order and referenced diagnosis" do
      customer = insert(:customer)
      [vehicle] = customer.vehicles
      order_attrs = order_with_all_params(customer.id, vehicle.id)
      {:ok, order} = Orders.create_order_with_diagnosis(order_attrs)

      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
      assert_raise Ecto.NoResultsError, fn -> Orders.get_diagnosis!(order.diagnosis.id) end
    end

    test "CustomerOrders.list_orders/1 returns the corresponding orders" do
      customer = insert(:customer)
      [vehicle] = customer.vehicles
      order_attrs = order_with_all_params(customer.id, vehicle.id)
      {:ok, order} = Orders.create_order_with_diagnosis(order_attrs)

      assert [a_order] = CustomerOrders.list_orders(customer.id)
      assert a_order.id == order.id
      assert [] = CustomerOrders.list_orders(0)
    end
    test "CustomerOrders.get_order/1 returns the corresponding orders" do
      customer = insert(:customer)
      [vehicle] = customer.vehicles
      order_attrs = order_with_all_params(customer.id, vehicle.id)
      {:ok, order} = Orders.create_order_with_diagnosis(order_attrs)

      assert {:ok, the_order} = CustomerOrders.get_order(customer.id, order.id)
      assert the_order.id == order.id
      assert the_order.customer_id == customer.id
      assert {:error, _} = CustomerOrders.get_order(customer.id, 0)
      assert {:error, _} = CustomerOrders.get_order(0, order.id)
    end
  end
end
