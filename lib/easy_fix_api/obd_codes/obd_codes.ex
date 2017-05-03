defmodule EasyFixApi.OBDCodes do
  @moduledoc """
  The boundary for the OBDCodes system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.Repo

  alias EasyFixApi.OBDCodes.OBDCode

  @doc """
  Returns the list of obd_codes.

  ## Examples

      iex> list_obd_codes()
      [%OBDCode{}, ...]

  """
  def list_obd_codes do
    Repo.all(OBDCode)
  end

  @doc """
  Gets a single obd_code.

  Raises `Ecto.NoResultsError` if the Obd code does not exist.

  ## Examples

      iex> get_obd_code!(123)
      %OBDCode{}

      iex> get_obd_code!(456)
      ** (Ecto.NoResultsError)

  """
  def get_obd_code!(id), do: Repo.get!(OBDCode, id)

  @doc """
  Creates a obd_code.

  ## Examples

      iex> create_obd_code(%{field: value})
      {:ok, %OBDCode{}}

      iex> create_obd_code(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_obd_code(attrs \\ %{}) do
    %OBDCode{}
    |> obd_code_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a obd_code.

  ## Examples

      iex> update_obd_code(obd_code, %{field: new_value})
      {:ok, %OBDCode{}}

      iex> update_obd_code(obd_code, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_obd_code(%OBDCode{} = obd_code, attrs) do
    obd_code
    |> obd_code_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a OBDCode.

  ## Examples

      iex> delete_obd_code(obd_code)
      {:ok, %OBDCode{}}

      iex> delete_obd_code(obd_code)
      {:error, %Ecto.Changeset{}}

  """
  def delete_obd_code(%OBDCode{} = obd_code) do
    Repo.delete(obd_code)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking obd_code changes.

  ## Examples

      iex> change_obd_code(obd_code)
      %Ecto.Changeset{source: %OBDCode{}}

  """
  def change_obd_code(%OBDCode{} = obd_code) do
    obd_code_changeset(obd_code, %{})
  end

  defp obd_code_changeset(%OBDCode{} = obd_code, attrs) do
    obd_code
    |> cast(attrs, [:code, :description])
    |> validate_required([:code, :description])
  end
end
