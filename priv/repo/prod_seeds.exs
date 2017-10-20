defmodule EasyFixApi.ProdSeeds do
  import EasyFixApi.StaticDataLoader
  import Ecto.Changeset

  require Logger

  alias EasyFixApi.Repo
  alias EasyFixApi.Cars.{Brand}
  alias EasyFixApi.Parts.{Part, PartSubGroup, PartGroup, PartSystem, GarageCategory}
  alias EasyFixApi.Payments.{Bank}
  alias EasyFixApi.Addresses

  def log_filename(filename) do
    Logger.info "Parsing and inserting #{filename}"
    filename
  end

  def run_vehicles_models do
    "lista_veiculos_modelos.csv"
    |> log_filename()
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

  def run_extra_garage_categories do
    Logger.info "Inserting extra garage_category: Autônomo"
    Repo.insert! %GarageCategory{name: "Autônomo"}
  end

  def run_parts do
    ~w[chassis motor interior exterior eletronica]
    |> Enum.each(&run_parts_system/1)
  end

  def run_parts_system(system) do
    "lista_pecas_#{system}.csv"
    |> log_filename()
    |> read_from_path_priv_repo()
    |> parse_parts()
    |> Enum.map(fn(part) ->
      %{name: name,
        group: group,
        sub_group: sub_group,
        garage_type: garage_type,
        repair_by_fixer: repair_by_fixer} = part

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
          |> cast(%{repair_by_fixer: repair_by_fixer}, [:repair_by_fixer])
          |> put_assoc(:part_sub_group, part_sub_group)
          |> put_assoc(:garage_category, garage_category)
        part = Repo.insert! part_changeset

      end)
    end)
  end

  def run_banks do
    "lista_bancos.csv"
    |> log_filename()
    |> read_from_path_priv_repo()
    |> parse_banks()
    |> Enum.map(fn(%{code: code, name: name}) ->
      Repo.insert!(%Bank{code: code, name: name})
    end)
  end

  def run_cities do
    Logger.info "Inserting state and city: São Paulo"
    {:ok, _sampa_state = %{id: sampa_id}} = Addresses.create_state(%{name: "São Paulo"})
    {:ok, _sampa_city} = Addresses.create_city(%{name: "São Paulo", state_id: sampa_id})
  end
end

EasyFixApi.ProdSeeds.run_parts
EasyFixApi.ProdSeeds.run_extra_garage_categories
EasyFixApi.ProdSeeds.run_vehicles_models
EasyFixApi.ProdSeeds.run_banks
EasyFixApi.ProdSeeds.run_cities
