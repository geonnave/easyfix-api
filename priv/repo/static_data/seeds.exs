defmodule EasyFixApi.StaticDataSeeds do
  import EasyFixApi.StaticDataLoader
  import Ecto.Changeset

  alias EasyFixApi.Repo
  alias EasyFixApi.Cars.{Brand}
  alias EasyFixApi.Parts.{Part, PartSubGroup, PartGroup, PartSystem, GarageCategory}
  alias EasyFixApi.Business.RepairByFixerPart

  def run_vehicles_models do
    "lista_veiculos_modelos.csv"
    |> read_from_path_priv_repo()
    |> transform_vehicles_models()
    |> Enum.map(fn({brand_name, models}) ->
      Repo.transaction(fn ->
        brand = Repo.insert!(%Brand{name: brand_name})
        for model <- models do
          model = Ecto.build_assoc(brand, :models, %{name: model})
          model = Repo.insert! model
        end
      end)
    end)
  end

  def run_parts do
    ~w[chassis, motor, interior, exterior, eletronica]
    |> Enum.each(&run_parts_system/1)
  end

  def run_parts_system(system) do
    "lista_pecas_#{system}.csv"
    |> read_from_path_priv_repo()
    |> transform_parts()
    |> Enum.map(fn(p = %{name: name, group: group, sub_group: sub_group, garage_type: garage_type, repair_by_fixer: repair_by_fixer}) ->
      IO.inspect name
      Repo.transaction(fn ->
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

        by_fixer =
          %RepairByFixerPart{}
          |> change()
          |> put_assoc(:part, part)
        by_fixer = Repo.insert! by_fixer

      end)
    end)
  end
end

EasyFixApi.StaticDataSeeds.run_parts_system("chassis")
# EasyFixApi.StaticDataSeeds.run_vehicles_models
