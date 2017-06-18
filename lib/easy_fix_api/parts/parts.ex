defmodule EasyFixApi.Parts do
  @moduledoc """
  The boundary for the Parts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.Repo

  alias EasyFixApi.Parts.GarageCategory

  @doc """
  Returns the list of garage_categories.

  ## Examples

      iex> list_garage_categories()
      [%GarageCategory{}, ...]

  """
  def list_garage_categories do
    Repo.all(GarageCategory)
  end

  @doc """
  Gets a single garage_category.

  Raises `Ecto.NoResultsError` if the Garage category does not exist.

  ## Examples

      iex> get_garage_category!(123)
      %GarageCategory{}

      iex> get_garage_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_garage_category!(id), do: Repo.get!(GarageCategory, id)

  @doc """
  Creates a garage_category.

  ## Examples

      iex> create_garage_category(%{field: value})
      {:ok, %GarageCategory{}}

      iex> create_garage_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_garage_category(attrs \\ %{}) do
    %GarageCategory{}
    |> garage_category_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a garage_category.

  ## Examples

      iex> update_garage_category(garage_category, %{field: new_value})
      {:ok, %GarageCategory{}}

      iex> update_garage_category(garage_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_garage_category(%GarageCategory{} = garage_category, attrs) do
    garage_category
    |> garage_category_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a GarageCategory.

  ## Examples

      iex> delete_garage_category(garage_category)
      {:ok, %GarageCategory{}}

      iex> delete_garage_category(garage_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_garage_category(%GarageCategory{} = garage_category) do
    Repo.delete(garage_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking garage_category changes.

  ## Examples

      iex> change_garage_category(garage_category)
      %Ecto.Changeset{source: %GarageCategory{}}

  """
  def change_garage_category(%GarageCategory{} = garage_category) do
    garage_category_changeset(garage_category, %{})
  end

  defp garage_category_changeset(%GarageCategory{} = garage_category, attrs) do
    garage_category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  alias EasyFixApi.Parts.PartSystem

  @doc """
  Returns the list of part_systems.

  ## Examples

      iex> list_part_systems()
      [%PartSystem{}, ...]

  """
  def list_part_systems do
    Repo.all(PartSystem)
  end

  @doc """
  Gets a single part_system.

  Raises `Ecto.NoResultsError` if the Part system does not exist.

  ## Examples

      iex> get_part_system!(123)
      %PartSystem{}

      iex> get_part_system!(456)
      ** (Ecto.NoResultsError)

  """
  def get_part_system!(id), do: Repo.get!(PartSystem, id)

  @doc """
  Creates a part_system.

  ## Examples

      iex> create_part_system(%{field: value})
      {:ok, %PartSystem{}}

      iex> create_part_system(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_part_system(attrs \\ %{}) do
    %PartSystem{}
    |> part_system_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a part_system.

  ## Examples

      iex> update_part_system(part_system, %{field: new_value})
      {:ok, %PartSystem{}}

      iex> update_part_system(part_system, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_part_system(%PartSystem{} = part_system, attrs) do
    part_system
    |> part_system_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PartSystem.

  ## Examples

      iex> delete_part_system(part_system)
      {:ok, %PartSystem{}}

      iex> delete_part_system(part_system)
      {:error, %Ecto.Changeset{}}

  """
  def delete_part_system(%PartSystem{} = part_system) do
    Repo.delete(part_system)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking part_system changes.

  ## Examples

      iex> change_part_system(part_system)
      %Ecto.Changeset{source: %PartSystem{}}

  """
  def change_part_system(%PartSystem{} = part_system) do
    part_system_changeset(part_system, %{})
  end

  defp part_system_changeset(%PartSystem{} = part_system, attrs) do
    part_system
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  alias EasyFixApi.Parts.PartGroup

  @doc """
  Returns the list of part_groups.

  ## Examples

      iex> list_part_groups()
      [%PartGroup{}, ...]

  """
  def list_part_groups do
    Repo.all(PartGroup)
  end

  @doc """
  Gets a single part_group.

  Raises `Ecto.NoResultsError` if the Part group does not exist.

  ## Examples

      iex> get_part_group!(123)
      %PartGroup{}

      iex> get_part_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_part_group!(id), do: Repo.get!(PartGroup, id)

  @doc """
  Creates a part_group.

  ## Examples

      iex> create_part_group(%{field: value})
      {:ok, %PartGroup{}}

      iex> create_part_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_part_group(attrs \\ %{}) do
    %PartGroup{}
    |> part_group_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a part_group.

  ## Examples

      iex> update_part_group(part_group, %{field: new_value})
      {:ok, %PartGroup{}}

      iex> update_part_group(part_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_part_group(%PartGroup{} = part_group, attrs) do
    part_group
    |> part_group_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PartGroup.

  ## Examples

      iex> delete_part_group(part_group)
      {:ok, %PartGroup{}}

      iex> delete_part_group(part_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_part_group(%PartGroup{} = part_group) do
    Repo.delete(part_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking part_group changes.

  ## Examples

      iex> change_part_group(part_group)
      %Ecto.Changeset{source: %PartGroup{}}

  """
  def change_part_group(%PartGroup{} = part_group) do
    part_group_changeset(part_group, %{})
  end

  defp part_group_changeset(%PartGroup{} = part_group, attrs) do
    part_group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  alias EasyFixApi.Parts.PartSubGroup

  @doc """
  Returns the list of part_sub_groups.

  ## Examples

      iex> list_part_sub_groups()
      [%PartSubGroup{}, ...]

  """
  def list_part_sub_groups do
    Repo.all(PartSubGroup)
  end

  @doc """
  Gets a single part_sub_group.

  Raises `Ecto.NoResultsError` if the Part sub group does not exist.

  ## Examples

      iex> get_part_sub_group!(123)
      %PartSubGroup{}

      iex> get_part_sub_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_part_sub_group!(id), do: Repo.get!(PartSubGroup, id)

  @doc """
  Creates a part_sub_group.

  ## Examples

      iex> create_part_sub_group(%{field: value})
      {:ok, %PartSubGroup{}}

      iex> create_part_sub_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_part_sub_group(attrs \\ %{}) do
    %PartSubGroup{}
    |> part_sub_group_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a part_sub_group.

  ## Examples

      iex> update_part_sub_group(part_sub_group, %{field: new_value})
      {:ok, %PartSubGroup{}}

      iex> update_part_sub_group(part_sub_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_part_sub_group(%PartSubGroup{} = part_sub_group, attrs) do
    part_sub_group
    |> part_sub_group_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PartSubGroup.

  ## Examples

      iex> delete_part_sub_group(part_sub_group)
      {:ok, %PartSubGroup{}}

      iex> delete_part_sub_group(part_sub_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_part_sub_group(%PartSubGroup{} = part_sub_group) do
    Repo.delete(part_sub_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking part_sub_group changes.

  ## Examples

      iex> change_part_sub_group(part_sub_group)
      %Ecto.Changeset{source: %PartSubGroup{}}

  """
  def change_part_sub_group(%PartSubGroup{} = part_sub_group) do
    part_sub_group_changeset(part_sub_group, %{})
  end

  defp part_sub_group_changeset(%PartSubGroup{} = part_sub_group, attrs) do
    part_sub_group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  alias EasyFixApi.Parts.Part

  @doc """
  Returns the list of parts.

  ## Examples

      iex> list_parts()
      [%Part{}, ...]

  """
  def list_parts do
    Repo.all(Part)
  end

  @doc """
  Gets a single part.

  Raises `Ecto.NoResultsError` if the Part does not exist.

  ## Examples

      iex> get_part!(123)
      %Part{}

      iex> get_part!(456)
      ** (Ecto.NoResultsError)

  """
  def get_part!(id), do: Repo.get!(Part, id)

  @doc """
  Creates a part.

  ## Examples

      iex> create_part(%{field: value})
      {:ok, %Part{}}

      iex> create_part(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_part(attrs \\ %{}) do
    %Part{}
    |> part_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a part.

  ## Examples

      iex> update_part(part, %{field: new_value})
      {:ok, %Part{}}

      iex> update_part(part, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_part(%Part{} = part, attrs) do
    part
    |> part_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Part.

  ## Examples

      iex> delete_part(part)
      {:ok, %Part{}}

      iex> delete_part(part)
      {:error, %Ecto.Changeset{}}

  """
  def delete_part(%Part{} = part) do
    Repo.delete(part)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking part changes.

  ## Examples

      iex> change_part(part)
      %Ecto.Changeset{source: %Part{}}

  """
  def change_part(%Part{} = part) do
    part_changeset(part, %{})
  end

  defp part_changeset(%Part{} = part, attrs) do
    part
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

end
