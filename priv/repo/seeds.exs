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

defmodule EasyFixApi.Seeds do
  import EasyFixApi.AdministrativeDataLoader

  def run_vehicles_models do
    "lista_veiculos_modelos.csv"
    |> read_from_path_priv_repo()
    |> transform_vehicles_models()
    |> Enum.map(fn({brand, models}) ->
      # IO.inspect brand
      for model <- models do
        # Repo.insert!(%VehicleModel{name: model, brand: brand})
      end
    end)
  end

  def run_parts do
    "lista_pecas_chassis.csv"
    |> read_from_path_priv_repo()
    |> transform_parts()
    |> IO.inspect
  end
end

EasyFixApi.Seeds.run_parts
EasyFixApi.Seeds.run_vehicles_models
