# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     EasyFixApi.Repo.insert!(%EasyFixApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias EasyFixApi.{Accounts, Repo}
alias EasyFixApi.Cars.{Brand}
alias EasyFixApi.Parts.{Part, PartSystem, GarageCategory}
alias EasyFixApi.Addresses.{State}
alias EasyFixApi.Payments.{Bank}
import Ecto.Changeset


# inserting one Part and its assocs
part_system = Repo.insert! %PartSystem{name: "Part System"}

part_group = Ecto.build_assoc(part_system, :part_groups, name: "Part Group")
part_group = Repo.insert! part_group

part_sub_group = Ecto.build_assoc(part_group, :part_sub_groups, name: "Part Sub Group")
part_sub_group = Repo.insert! part_sub_group

garage_category = Repo.insert! %GarageCategory{name: "Example"}

part_changeset = %Part{} |> cast(%{name: "a part"}, [:name]) |> put_assoc(:part_sub_group, part_sub_group) |> put_assoc(:garage_category, garage_category)
part = Repo.insert! part_changeset

# inserting one Bank
Repo.insert!(%Bank{code: "1", name: "A Bank"})

# inserting one State
state = Repo.insert!(%State{name: "A State"})

city = Ecto.build_assoc(state, :cities, name: "A City")
city = Repo.insert! city

# inserting one Vehicle
brand = Repo.insert!(%Brand{name: "A Brand"})

model = Ecto.build_assoc(brand, :models, name: "A Model")
model = Repo.insert! model

# customer
customer_attrs = %{
  "email" => "customer@email.com",
  "password" => "customer@email.com",
  "accept_easyfix_policy" => "2017-08-06T17:44:57.913808Z",
  "cpf" => "some cpf",
  "name" => "some name",
  "phone" => "some phone",
  "address" => %{
    "address_line1" => "some address_line1",
    "address_line2" => "some address_line2",
    "city_id" => 1,
    "neighborhood" => "some neighborhood",
    "postal_code" => "some postal_code"
  },
  "bank_account" => %{
    "agency" => "1111",
    "bank_id" => 1,
    "number" => "1234"
  },
  "vehicles" => [
    %{
      "model_id" => 1,
      "model_year" => "2011",
      "plate" => "cfd-2011",
      "vehicle_id_number" => "9BW ZZZ377 VT 004251",
      "mileage" => 30_000,
      "production_year" => "2011"
    }
  ]
}
{:ok, _customer} = Accounts.create_customer(customer_attrs)

# garage
garage_attrs = %{
  "email" => "garage@email.com",
  "password" => "garage@email.com",
  "phone" => "some phone",
  "cnpj" => "some cnpj",
  "garage_categories_ids" => [garage_category.id],
  "name" => "some name",
  "owner_name" => "some owner_name",
  "address" => %{
    "address_line1" => "some address_line1",
    "address_line2" => "some address_line2",
    "city_id" => 1,
    "neighborhood" => "some neighborhood",
    "postal_code" => "some postal_code"
  },
  "bank_account" => %{
    "agency" => "1111",
    "bank_id" => 1,
    "number" => "1234"
  },
}
{:ok, _garage} = Accounts.create_garage(garage_attrs)
