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
      attrs["garage_categories"]
      # |> Enum.map(fn %{"id" => id} -> id end)
      |> Enum.map(&Repo.get(GarageCategory, &1))

    %Garage{}
    |> garage_changeset(attrs)
    |> put_assoc(:garage_categories, garage_categories)
    |> Repo.insert()
  end

  def update_garage(%Garage{} = garage, attrs) do
    garage
    |> garage_changeset(attrs)
    |> Repo.update()
  end

  def delete_garage(%Garage{} = garage) do
    Repo.delete(garage)
  end

  def change_garage(%Garage{} = garage) do
    garage_changeset(garage, %{})
  end

  def garage_changeset(%Garage{} = garage, attrs) do
    garage
    |> cast(attrs, [:name, :owner_name, :email, :password_hash, :phone, :cnpj])
    |> validate_required([:name, :owner_name, :email, :password_hash, :phone, :cnpj])
  end

  def garage_preload(garage_or_garages, field) do
    Repo.preload(garage_or_garages, field)
  end
end
