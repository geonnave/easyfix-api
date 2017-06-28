defmodule EasyFixApi.Cars do
  @moduledoc """
  The boundary for the Cars system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.Repo

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
end
