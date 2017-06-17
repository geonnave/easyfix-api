defmodule EasyFixApi.StaticDataSeeds do
  import EasyFixApi.AdministrativeDataLoader
  alias EasyFixApi.Repo
  alias EasyFixApi.Cars.{Brand, Model}

  def run_vehicles_models do
    "lista_veiculos_modelos.csv"
    |> read_from_path_priv_repo()
    |> transform_vehicles_models()
    |> Enum.map(fn({brand_name, models}) ->
      Ecto.transaction(fn ->
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
    |> Enum.map(fn(%{name: name, group: group, sub_group: sub_group, garage_type: garage_type, repair_by_fixer: repair_by_fixer}) ->
      Ecto.transaction(fn ->
        # part_system = Repo.insert! %PartSystem{name: system}

        # part_group = Ecto.build_assoc(part_system, :part_groups, name: group)
        # part_group = Repo.insert! part_group

        # part_sub_group = Ecto.build_assoc(part_group, :part_sub_groups, name: sub_group)
        # part_sub_group = Repo.insert! part_sub_group

        # garage_category = Repo.insert! %GarageCategory{name: garage_type}

        # part = %Part{name: name, repair_by_fixer: repair_by_fixer}

      end)
      IO.inspect part
    end)
  end
end

EasyFixApi.StaticDataSeeds.run_parts_system("chassis")
# EasyFixApi.StaticDataSeeds.run_vehicles_models
