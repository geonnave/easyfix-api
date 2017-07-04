defmodule EasyFixApi.Garages do
  @moduledoc """
  The boundary for the Garages system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.Repo

  alias EasyFixApi.Garages.Garage
  alias EasyFixApi.Parts.GarageCategory

  def list_garages do
    Repo.all(Garage)
    |> Repo.preload(:garage_categories)
  end

  def get_garage!(id), do: Repo.get!(Garage, id) |> Repo.preload(:garage_categories)

  def create_garage(attrs \\ %{}) do
    garage_categories =
      attrs[:garage_categories]
      |> Enum.map(&Repo.get(GarageCategory, &1))

    %Garage{}
    |> Garage.registration_changeset(attrs[:garage])
    |> put_assoc(:garage_categories, garage_categories)
    |> Repo.insert()
  end

  def update_garage(%Garage{} = garage, attrs) do
    inserted_category_ids = for %{id: id} <- garage.garage_categories, do: id

    garage_categories =
      attrs[:garage_categories]
      |> Enum.concat(inserted_category_ids)
      |> Enum.map(&Repo.get(GarageCategory, &1))

    garage
    |> Garage.changeset(attrs[:garage])
    |> put_assoc(:garage_categories, garage_categories)
    |> Repo.update()
  end

  def delete_garage(%Garage{} = garage) do
    Repo.delete(garage)
  end

  def change_garage(%Garage{} = garage) do
    Garage.changeset(garage, %{})
  end

  def garage_preload(garage_or_garages, field) do
    Repo.preload(garage_or_garages, field)
  end
end
