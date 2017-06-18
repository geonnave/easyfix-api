defmodule EasyFixApi.Business do
  @moduledoc """
  The boundary for the Business system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.Repo

  alias EasyFixApi.Business.RepairByFixerPart

  @doc """
  Returns the list of repair_by_fixer_parts.

  ## Examples

      iex> list_repair_by_fixer_parts()
      [%RepairByFixerPart{}, ...]

  """
  def list_repair_by_fixer_parts do
    Repo.all(RepairByFixerPart)
  end

  @doc """
  Gets a single repair_by_fixer_part.

  Raises `Ecto.NoResultsError` if the Repair by fixer part does not exist.

  ## Examples

      iex> get_repair_by_fixer_part!(123)
      %RepairByFixerPart{}

      iex> get_repair_by_fixer_part!(456)
      ** (Ecto.NoResultsError)

  """
  def get_repair_by_fixer_part!(id), do: Repo.get!(RepairByFixerPart, id)

  @doc """
  Creates a repair_by_fixer_part.

  ## Examples

      iex> create_repair_by_fixer_part(%{field: value})
      {:ok, %RepairByFixerPart{}}

      iex> create_repair_by_fixer_part(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_repair_by_fixer_part(attrs \\ %{}) do
    %RepairByFixerPart{}
    |> repair_by_fixer_part_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a repair_by_fixer_part.

  ## Examples

      iex> update_repair_by_fixer_part(repair_by_fixer_part, %{field: new_value})
      {:ok, %RepairByFixerPart{}}

      iex> update_repair_by_fixer_part(repair_by_fixer_part, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_repair_by_fixer_part(%RepairByFixerPart{} = repair_by_fixer_part, attrs) do
    repair_by_fixer_part
    |> repair_by_fixer_part_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a RepairByFixerPart.

  ## Examples

      iex> delete_repair_by_fixer_part(repair_by_fixer_part)
      {:ok, %RepairByFixerPart{}}

      iex> delete_repair_by_fixer_part(repair_by_fixer_part)
      {:error, %Ecto.Changeset{}}

  """
  def delete_repair_by_fixer_part(%RepairByFixerPart{} = repair_by_fixer_part) do
    Repo.delete(repair_by_fixer_part)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking repair_by_fixer_part changes.

  ## Examples

      iex> change_repair_by_fixer_part(repair_by_fixer_part)
      %Ecto.Changeset{source: %RepairByFixerPart{}}

  """
  def change_repair_by_fixer_part(%RepairByFixerPart{} = repair_by_fixer_part) do
    repair_by_fixer_part_changeset(repair_by_fixer_part, %{})
  end

  defp repair_by_fixer_part_changeset(%RepairByFixerPart{} = repair_by_fixer_part, attrs) do
    repair_by_fixer_part
    |> cast(attrs, [])
    |> validate_required([])
  end
end
