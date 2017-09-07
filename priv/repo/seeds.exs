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

alias EasyFixApi.{Cars, Parts, Accounts, Business, Addresses, Orders, Payments, GuardianSerializer, Repo}
alias EasyFixApi.Cars.{Brand, Model}
alias EasyFixApi.Parts.{Part, PartSubGroup, PartGroup, PartSystem, GarageCategory}
alias EasyFixApi.Accounts.{User, Garage}
alias EasyFixApi.Business.RepairByFixerPart
alias EasyFixApi.Addresses.{State, City, Address}
alias EasyFixApi.Orders.{Diagnosis, Budget}
alias EasyFixApi.Payments.{Bank, BankAccount}
import Ecto.Changeset


# inserting one Part and its assocs
part_system = Repo.insert! %PartSystem{name: "Chassis"}

part_group = Ecto.build_assoc(part_system, :part_groups, name: "Direção")
part_group = Repo.insert! part_group

part_sub_group = Ecto.build_assoc(part_group, :part_sub_groups, name: "Freios")
part_sub_group = Repo.insert! part_sub_group

garage_category = Repo.insert! %GarageCategory{name: "Mecânica"}

part_changeset = %Part{} |> cast(%{name: "disco de freio"}, [:name]) |> put_assoc(:part_sub_group, part_sub_group) |> put_assoc(:garage_category, garage_category)
part = Repo.insert! part_changeset

# inserting one Bank
Repo.insert!(%Bank{code: "1", name: "RockBank"})

# inserting one State
state = Repo.insert!(%State{name: "São Paulo"})

city = Ecto.build_assoc(state, :cities, name: "São Paulo")
city = Repo.insert! city

# inserting one Vehicle
brand = Repo.insert!(%Brand{name: "RockBrand"})

model = Ecto.build_assoc(brand, :models, name: "Rockcar")
model = Repo.insert! model
