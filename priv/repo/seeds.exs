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

defmodule AdministrativeDB do
  def path_priv_repo(name) do
    Path.join([:code.priv_dir(:easy_fix_api), "repo", name])
  end

  def read_vehicles_models do
    vehicles_models_filename = path_priv_repo("lista_veiculos_modelos.csv")
    {brands_to_models, _} =
      vehicles_models_filename
      |> File.stream!
      |> CSV.decode!
      |> Enum.to_list
      |> Enum.reduce({%{}, ""}, fn([brand, model], {acc, last_brand}) ->
      brand = if brand == "", do: last_brand, else: brand
      if model == "" do
        IO.inspect [brand, model]
      end
      brand_models = Map.get(acc, brand, [])
      acc = put_in(acc, [brand], [model | brand_models])
      {acc, brand}
    end)
      brands_to_models
  end
end

AdministrativeDB.read_vehicles_models
|> Enum.map(fn({brand, models}) ->
  for model <- models do
    # Repo.insert!(%VehicleModel{name: model, brand: brand})
  end
end)

