defmodule EasyFixApi.Factory do
  use ExMachina.Ecto, repo: EasyFixApi.Repo

  alias EasyFixApi.Addresses.{Address, City, State}
  alias EasyFixApi.Accounts.{User, Garage, Customer}
  alias EasyFixApi.Payments.{Bank, BankAccount}
  alias EasyFixApi.Orders.{Diagnostic, DiagnosticPart, Budget, BudgetPart, Order}
  alias EasyFixApi.Parts.{Part, PartSubGroup, PartGroup, PartSystem, GarageCategory}

  def order_factory do
    %Order{
      status: "new",
      sub_status: "new",
      opening_date: "2017-08-06T17:44:57.913808Z",
      conclusion_date: "2017-08-07T17:44:57.913808Z",
    }
  end
  def order_with_diagnostic_params do
    params_for(:order)
    |> put_in([:diagnostic], diagnostic_with_diagnostic_parts_params())
  end

  def budget_factory do
    %Budget{
      service_cost: 42,
      status: "new",
      sub_status: "new",
      opening_date: "2017-08-06T17:44:57.913808Z",
      due_date: "2017-08-07T17:44:57.913808Z",
    }
  end

  def budget_part_factory do
    %BudgetPart{
      part: build(:part),
      # budget: build(:budget),
      quantity: 1,
      price: 4200
    }
  end

  def diagnostic_part_factory do
    %DiagnosticPart{
      part: build(:part),
      quantity: 1,
    }
  end
  def diagnostic_parts_with_diagnostic(diagnostic) do
    build(:diagnostic_part, diagnostic: diagnostic)
  end
  def diagnostic_parts_params(n_parts) do
    1..n_parts
    |> Enum.map(fn _ -> insert(:part) end)
    |> Enum.map(fn part -> %{part_id: part.id, quantity: 1} end)
  end

  def diagnostic_factory do
    %Diagnostic{
      accepts_used_parts: true,
      comment: "some comment",
      need_tow_truck: true,
      status: "some status",
      expiration_date: "2017-08-05 17:44:57.913808Z",
      }
  end
  def diagnostic_with_diagnostic_parts_params do
    params_for(:diagnostic)
    |> put_in([:parts], diagnostic_parts_params(2))
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
    }
  end
  def customer_with_all_params do
    address_attrs = params_with_assocs(:address)
    bank_account_attrs = params_with_assocs(:bank_account)
    user_attrs = params_for(:user_with_password)

    params_with_assocs(:customer)
    |> put_in([:email], user_attrs[:email])
    |> put_in([:password], user_attrs[:password])
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
      user: build(:user),
      garage_categories: build_list(2, :garage_category)
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
      email: "some@email.com",
      # password: "some password",
      password_hash: "$2b$12$jOt0r0C8tEVmmLsW6rd/pOGjgJn1pWmqob0KpIPYwfWMkgFlcto/K",
    }
  end
  def user_with_password_factory do
    %User{
      email: "some@email.com",
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
end