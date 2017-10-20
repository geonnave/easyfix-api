defmodule EasyFixApi.Factory do
  use ExMachina.Ecto, repo: EasyFixApi.Repo

  alias EasyFixApi.Addresses.{Address, City, State}
  alias EasyFixApi.Accounts.{User, Garage, Customer}
  alias EasyFixApi.Payments.{Bank, BankAccount}
  alias EasyFixApi.Orders.{Diagnosis, DiagnosisPart, Quote, QuotePart, Order}
  alias EasyFixApi.Orders
  alias EasyFixApi.Parts.{Part, PartSubGroup, PartGroup, PartSystem, GarageCategory}
  alias EasyFixApi.Cars.{Model, Brand, Vehicle}

  def order_factory do
    %Order{
    }
  end
  def order_with_all_params(customer_id, vehicle_id) do
    params_for(:order)
    |> put_in([:diagnosis], diagnosis_with_diagnosis_parts_params(vehicle_id))
    |> put_in([:customer_id], customer_id)
  end

  def quote_factory do
    %Quote{
      service_cost: 42,
      status: "new",
      sub_status: "new",
      due_date: "2017-08-07T17:44:57.913808Z",
      quotes_parts: build_list(2, :quote_part)
    }
  end
  def with_service_cost(quote, sc), do: %{quote | service_cost: Money.new(sc)}
  def with_total_amount(quote, total_amount), do: %{quote | total_amount: Money.new(total_amount)}
  def with_quotes_parts_price(quote, price) do
    %{quote |
      quotes_parts: Enum.map(quote.quotes_parts, fn quote_part ->
        %{quote_part | price: Money.new(price)}
      end)
    }
  end

  def quote_with_all_params do
    garage = insert(:garage)
    customer = insert(:customer)
    [vehicle] = customer.vehicles
    order_attrs = order_with_all_params(customer.id, vehicle.id)
    {:ok, order} = Orders.create_order_with_diagnosis(order_attrs)

    quote_attrs =
      params_for(:quote)
      |> put_in([:parts], parts_for_quote())
      |> put_in([:diagnosis_id], order.diagnosis.id)
      |> put_in([:issuer_id], garage.id)
      |> put_in([:issuer_type], "garage")

    {quote_attrs, garage, order}
  end

  def quote_part_factory do
    %QuotePart{
      part: build(:part),
      # quote: build(:quote),
      quantity: 1,
      price: 4200
    }
  end

  def parts_for_quote do
    [
      %{part_id: insert(:part).id, price: 4200, quantity: 1},
      %{part_id: insert(:part).id, price: 200, quantity: 4},
    ]
  end

  def diagnosis_part_factory do
    %DiagnosisPart{
      part: build(:part),
      quantity: 1,
    }
  end
  def with_part(diagnosis_part, part) do
    %{diagnosis_part | part: part}
  end
  def diagnosis_parts_with_diagnosis(diagnosis) do
    build(:diagnosis_part, diagnosis: diagnosis)
  end
  def diagnosis_parts_params(n_parts) do
    1..n_parts
    |> Enum.map(fn _ -> insert(:part) end)
    |> Enum.map(fn part -> %{part_id: part.id, quantity: 1} end)
  end

  def diagnosis_factory do
    %Diagnosis{
      accepts_used_parts: true,
      comment: "some comment",
      need_tow_truck: true,
      status: "some status",
      expiration_date: "2017-08-05 17:44:57.913808Z",
      vehicle: build(:vehicle),
    }
  end
  def with_diagnosis_parts(diagnosis, diagnosis_parts) do
    %{diagnosis | diagnosis_parts: diagnosis_parts}
  end
  def diagnosis_with_diagnosis_parts_params(vehicle_id) do
    params_for(:diagnosis)
    |> put_in([:parts], diagnosis_parts_params(2))
    |> put_in([:vehicle_id], vehicle_id)
  end

  def state_factory do
    %State{
      name: "some name",
    }
  end

  def city_factory do
    %City{
      name: "some name",
      state: build(:state)
    }
  end

  def address_factory do
    %Address{
      address_line1: "some address_line1",
      address_line2: "some address_line2",
      neighborhood: "some neighborhood",
      postal_code: "some postal_code",
      city: build(:city),
    }
  end

  def customer_factory do
    %Customer{
      name: "some name",
      phone: "some phone",
      cpf: "some cpf",
      accept_easyfix_policy: "2017-08-05 17:44:57.913808Z",
      user: build(:user),
      bank_account: build(:bank_account),
      address: build(:address),
      vehicles: build_list(1, :vehicle_with_model),
    }
  end
  def customer_with_all_params do
    address_attrs = params_with_assocs(:address)
    bank_account_attrs = params_with_assocs(:bank_account)
    vehicle_attrs = params_with_assocs(:vehicle_with_model)
    user_attrs = params_for(:user_with_password)

    params_with_assocs(:customer)
    |> put_in([:email], user_attrs[:email])
    |> put_in([:password], user_attrs[:password])
    |> put_in([:vehicles], [vehicle_attrs])
    |> put_in([:address], address_attrs)
    |> put_in([:bank_account], bank_account_attrs)
  end

  def address_with_user(user) do
    build(:address, user: user)
  end

  def garage_factory do
    %Garage{
      cnpj: "some cnpj",
      name: "some name",
      owner_name: "some owner_name",
      phone: "some phone",
      garage_categories: build_list(2, :garage_category),
      user: build(:user),
      address: build(:address),
    }
  end
  def garage_with_all_params do
    address_attrs = params_with_assocs(:address)
    bank_account_attrs = params_with_assocs(:bank_account)
    user_attrs = params_for(:user_with_password)
    [gc1, gc2] = insert_list(2, :garage_category)

    params_with_assocs(:garage)
    |> put_in([:email], user_attrs[:email])
    |> put_in([:password], user_attrs[:password])
    |> put_in([:address], address_attrs)
    |> put_in([:bank_account], bank_account_attrs)
    |> put_in([:garage_categories_ids], [gc1.id, gc2.id])
  end

  def user_factory do
    %User{
      email: sequence("some@email.com"),
      # password: "some password",
      password_hash: "$2b$12$jOt0r0C8tEVmmLsW6rd/pOGjgJn1pWmqob0KpIPYwfWMkgFlcto/K",
    }
  end
  def user_with_password_factory do
    %User{
      email: sequence("some@email.com"),
      password: "some password",
    }
  end

  def garage_category_factory do
    %GarageCategory{
      name: sequence("some category")
    }
  end

  def part_factory do
    %Part{
      name: sequence("some part"),
      part_sub_group: build(:part_sub_group),
      garage_category: build(:garage_category),
    }
  end
  def with_category(part, gc) do
    %{part | garage_category: gc}
  end

  def part_sub_group_factory do
    %PartSubGroup{
      name: sequence("some part_sub_group"),
      part_group: build(:part_group)
    }
  end
  def part_group_factory do
    %PartGroup{
      name: sequence("some part group"),
      part_system: build(:part_system)
    }
  end
  def part_system_factory do
    %PartSystem{
      name: sequence("some part")
    }
  end

  def vehicle_with_all_params do
    params_for(:vehicle)
    |> put_in([:model_id], insert(:model).id)
  end
  def vehicle_with_model_factory do
    %Vehicle{
      model_year: "2010",
      production_year: "2010",
      plate: "cfd-2211",
      vehicle_id_number: "9BW ZZZ377 VT 004251",
      mileage: 30_000,
      model: build(:model),
    }
  end
  def vehicle_factory do
    %Vehicle{
      model_year: "2010",
      production_year: "2010",
      plate: "cfd-2211",
      vehicle_id_number: "9BW ZZZ377 VT 004251",
      mileage: 30_000,
      model: build(:model),
    }
  end
  def model_factory do
    %Model{
      name: "Model S",
      brand: build(:brand),
    }
  end
  def brand_factory do
    %Brand{
      name: "Tesla"
    }
  end

  def bank_factory do
    %Bank{
      name: "Itau",
      code: "341"
    }
  end

  def bank_account_factory do
    %BankAccount{
      agency: "2222",
      number: "2345",
      bank: build(:bank)
    }
  end

  def with_name(struct, name) do
    %{struct | name: name}
  end
end