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

defmodule EasyFixApi.StaticDataSeeds do
  import EasyFixApi.StaticDataLoader
  import Ecto.Changeset

  alias EasyFixApi.Repo
  alias EasyFixApi.Cars.{Brand}
  alias EasyFixApi.Parts.{Part, PartSubGroup, PartGroup, PartSystem, GarageCategory}
  alias EasyFixApi.Payments.{Bank}
  alias EasyFixApi.Business.RepairByFixerPart
  alias EasyFixApi.Addresses

  def run_vehicles_models do
    "lista_veiculos_modelos.csv"
    |> read_from_path_priv_repo()
    |> parse_vehicles_models()
    |> Enum.map(fn({brand_name, models}) ->
      Repo.transaction(fn ->
        brand = Repo.insert!(%Brand{name: brand_name})
        for model <- models do
          model = Ecto.build_assoc(brand, :models, %{name: model})
          Repo.insert! model
        end
      end)
    end)
  end

  def run_parts do
    ~w[chassis motor interior exterior eletronica]
    |> Enum.each(&run_parts_system/1)
  end

  def run_parts_system(system) do
    "lista_pecas_#{system}.csv"
    |> read_from_path_priv_repo()
    |> parse_parts()
    |> Enum.map(fn(%{name: name, group: group, sub_group: sub_group, garage_type: garage_type, repair_by_fixer: repair_by_fixer}) ->
      Repo.transaction(fn ->
        system = String.capitalize(system)
        part_system = case Repo.get_by(PartSystem, name: system) do
                        nil ->
                          Repo.insert! %PartSystem{name: system}
                        part_system ->
                          part_system
                      end

        part_group = Ecto.build_assoc(part_system, :part_groups, name: group)
        part_group = case Repo.get_by(PartGroup, name: group) do
                        nil ->
                         Repo.insert! part_group
                        part_group ->
                          part_group
                      end

        part_sub_group = Ecto.build_assoc(part_group, :part_sub_groups, name: sub_group)
        part_sub_group = case Repo.get_by(PartSubGroup, name: sub_group) do
                           nil ->
                             Repo.insert! part_sub_group
                           part_sub_group ->
                             part_sub_group
                         end

        garage_category = case Repo.get_by(GarageCategory, name: garage_type) do
                            nil ->
                              Repo.insert! %GarageCategory{name: garage_type}
                            garage_category ->
                              garage_category
                          end

        part_changeset =
          %Part{}
          |> cast(%{name: name}, [:name])
          |> put_assoc(:part_sub_group, part_sub_group)
          |> put_assoc(:garage_category, garage_category)
        part = Repo.insert! part_changeset

        if repair_by_fixer do
          by_fixer =
            %RepairByFixerPart{}
            |> change()
            |> put_assoc(:part, part)
          Repo.insert! by_fixer
        end

      end)
    end)
  end

  def run_banks do
    "lista_bancos.csv"
    |> read_from_path_priv_repo()
    |> parse_banks()
    |> Enum.map(fn(%{code: code, name: name}) ->
      Repo.insert!(%Bank{code: code, name: name})
    end)
  end

  def run_cities do
    {:ok, _sampa_state = %{id: sampa_id}} = Addresses.create_state(%{name: "São Paulo"})
    {:ok, _sampa_city} = Addresses.create_city(%{name: "São Paulo", state_id: sampa_id})
  end
end

# EasyFixApi.StaticDataSeeds.run_parts
# EasyFixApi.StaticDataSeeds.run_vehicles_models
# EasyFixApi.StaticDataSeeds.run_banks
# EasyFixApi.StaticDataSeeds.run_cities
