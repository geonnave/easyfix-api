defmodule EasyFixApi.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.Repo

  alias EasyFixApi.Accounts.User

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by(clauses) do
    Repo.get_by(User, clauses)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias EasyFixApi.Accounts.Garage
  alias EasyFixApi.Parts.GarageCategory

  def list_garages do
    Repo.all(Garage)
    |> Repo.preload(:garage_categories)
    |> Repo.preload(:user)
  end

  def get_garage!(id) do
    Repo.get!(Garage, id)
    |> Repo.preload(:garage_categories)
    |> Repo.preload(:user)
  end

  def create_garage(attrs \\ %{}) do
    garage_categories =
      attrs[:garage_categories]
      |> Enum.map(&Repo.get(GarageCategory, &1))

    Repo.transaction fn ->
      {:ok, user} = create_user(attrs[:garage])

      %Garage{}
      |> Garage.changeset(attrs[:garage])
      |> put_assoc(:user, user)
      |> put_assoc(:garage_categories, garage_categories)
      |> Repo.insert!()
    end
  end

  def update_garage(%Garage{} = garage, attrs) do
    inserted_category_ids = for %{id: id} <- garage.garage_categories, do: id

    garage_categories =
      attrs[:garage_categories]
      |> Enum.concat(inserted_category_ids)
      |> Enum.map(&Repo.get(GarageCategory, &1))

    Repo.transaction fn ->
      {:ok, user} = update_user(garage.user, attrs[:garage])

      garage
      |> Garage.changeset(attrs[:garage])
      |> put_assoc(:user, user)
      |> put_assoc(:garage_categories, garage_categories)
      |> Repo.update!()

      get_garage!(garage.id)
    end
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
