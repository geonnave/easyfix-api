defmodule EasyFixApi.Factory do
  use ExMachina.Ecto, repo: EasyFixApi.Repo

  alias EasyFixApi.Addresses.{Address, City, State}
  alias EasyFixApi.Accounts.{User, Garage}
  alias EasyFixApi.Parts.GarageCategory

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

  def user_factory do
    %User{
      email: "some@email.com",
      # password: "some password",
      password_hash: "$2b$12$jOt0r0C8tEVmmLsW6rd/pOGjgJn1pWmqob0KpIPYwfWMkgFlcto/K",
    }
  end

  def garage_category_factory do
    %GarageCategory{
      name: sequence("some category")
    }
  end
end