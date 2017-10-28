defmodule EasyFixApi.Parts do
  @moduledoc """
  The boundary for the Parts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.Repo

  alias EasyFixApi.Parts.GarageCategory

  def list_garage_categories do
    Repo.all(GarageCategory)
  end

  def get_garage_category!(id), do: Repo.get!(GarageCategory, id)

  def change_garage_category(%GarageCategory{} = garage_category) do
    garage_category_changeset(garage_category, %{})
  end

  defp garage_category_changeset(%GarageCategory{} = garage_category, attrs) do
    garage_category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  alias EasyFixApi.Parts.PartSystem

  def list_part_systems do
    Repo.all(PartSystem)
  end

  def get_part_system!(id), do: Repo.get!(PartSystem, id)

  def change_part_system(%PartSystem{} = part_system) do
    part_system_changeset(part_system, %{})
  end

  defp part_system_changeset(%PartSystem{} = part_system, attrs) do
    part_system
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  alias EasyFixApi.Parts.PartGroup

  def list_part_groups do
    Repo.all(PartGroup)
  end

  def get_part_group!(id), do: Repo.get!(PartGroup, id)

  def change_part_group(%PartGroup{} = part_group) do
    part_group_changeset(part_group, %{})
  end

  defp part_group_changeset(%PartGroup{} = part_group, attrs) do
    part_group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  alias EasyFixApi.Parts.PartSubGroup

  def list_part_sub_groups do
    Repo.all(PartSubGroup)
  end

  def get_part_sub_group!(id), do: Repo.get!(PartSubGroup, id)

  def change_part_sub_group(%PartSubGroup{} = part_sub_group) do
    part_sub_group_changeset(part_sub_group, %{})
  end

  defp part_sub_group_changeset(%PartSubGroup{} = part_sub_group, attrs) do
    part_sub_group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  alias EasyFixApi.Parts.{Part}

  def list_parts do
    Repo.all(Part)
    |> Repo.preload(Part.all_nested_assocs)
  end

  def get_part!(id) do
    Repo.get!(Part, id)
    |> Repo.preload(Part.all_nested_assocs)
  end

  def create_part(attrs \\ %{}, part_sub_group, garage_category) do
    with changeset = %{valid?: true} <- create_part_changeset(attrs) do
      changeset
      |> put_assoc(:part_sub_group, part_sub_group)
      |> put_assoc(:garage_category, garage_category)
      |> Repo.insert()
    else
      changeset ->
        {:error, changeset}
    end
  end

  def update_part(%Part{} = part, attrs) do
    part
    |> Part.changeset(attrs)
    |> Repo.update()
  end

  def delete_part(%Part{} = part) do
    Repo.delete(part)
  end

  def create_part_changeset(attrs) do
    %Part{}
    |> Part.changeset(attrs)
    |> validate_required([:name, :repair_by_fixer])
  end
end
