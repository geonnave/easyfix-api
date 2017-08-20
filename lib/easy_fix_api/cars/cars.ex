defmodule EasyFixApi.Cars do
  @moduledoc """
  The boundary for the Cars system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.{Repo, Helpers}

  alias EasyFixApi.Cars.Brand

  def list_brands do
    Repo.all(Brand)
  end

  def get_brand!(id), do: Repo.get!(Brand, id)

  def change_brand(%Brand{} = brand) do
    brand_changeset(brand, %{})
  end

  defp brand_changeset(%Brand{} = brand, attrs) do
    brand
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  alias EasyFixApi.Cars.Model

  def list_models do
    Repo.all(Model)
    |> Repo.preload(:brand)
  end

  def get_model!(id), do: Repo.get!(Model, id) |> Repo.preload(:brand)

  def change_model(%Model{} = model) do
    model_changeset(model, %{})
  end

  defp model_changeset(%Model{} = model, attrs) do
    model
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  alias EasyFixApi.Cars.Vehicle

  def list_vehicle do
    Repo.all(Vehicle)
  end

  def get_vehicle!(id) do
    Repo.get!(Vehicle, id)
    |> Repo.preload(Vehicle.all_nested_assocs)
  end

  def create_vehicle(attrs \\ %{}) do
    with vehicle_changeset = %{valid?: true} <- Vehicle.create_changeset(attrs),
         vehicle_assoc_changeset = %{valid?: true} <- Vehicle.assoc_changeset(attrs),
         vehicle_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(vehicle_assoc_changeset) do

      model = get_model!(vehicle_assoc_attrs[:model_id])

      vehicle_changeset
      |> put_change(:plate, String.upcase(vehicle_changeset.changes[:plate]))
      |> put_assoc(:model, model)
      |> Repo.insert()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def update_vehicle(%Vehicle{} = vehicle, attrs) do
    vehicle
    |> Vehicle.changeset(attrs)
    |> Repo.update()
  end

  def delete_vehicle(%Vehicle{} = vehicle) do
    Repo.delete(vehicle)
  end

end
