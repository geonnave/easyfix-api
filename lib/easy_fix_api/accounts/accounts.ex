defmodule EasyFixApi.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.Repo

  alias EasyFixApi.Accounts.User
  alias EasyFixApi.Accounts.Garage
  alias EasyFixApi.Parts.GarageCategory

  def get_by_email("garage", email) do
    from(g in Garage,
      join: u in User,
      on: g.user_id == u.id,
      where: u.email == ^email,
      preload: [:user, :garage_categories]
    ) |> Repo.one
  end

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
    case Garage.assoc_changeset(attrs) do
      assoc_changeset = %{valid?: true} ->
        garage_assocs = apply_changes(assoc_changeset)
        garage_categories =
          garage_assocs[:garage_categories]
          |> Enum.map(&Repo.get(GarageCategory, &1))

        Repo.transaction fn ->
          {:ok, user} = create_user(attrs)

          %Garage{}
          |> Garage.changeset(attrs)
          |> put_assoc(:user, user)
          |> put_assoc(:garage_categories, garage_categories)
          |> Repo.insert!()
        end
      invalid_assoc_changeset ->
        {:error, invalid_assoc_changeset}
    end
  end

  def update_garage(%Garage{} = garage, attrs) do
    case Garage.assoc_changeset(attrs) do
      assoc_changeset = %{valid?: true} ->
        inserted_category_ids = for %{id: id} <- garage.garage_categories, do: id

        garage_assocs = apply_changes(assoc_changeset)
        garage_categories =
          garage_assocs[:garage_categories]
          |> Enum.concat(inserted_category_ids)
          |> Enum.map(&Repo.get(GarageCategory, &1))

        Repo.transaction fn ->
          {:ok, user} = update_user(garage.user, attrs)

          garage
          |> Garage.changeset(attrs)
          |> put_assoc(:user, user)
          |> put_assoc(:garage_categories, garage_categories)
          |> Repo.update!()

          get_garage!(garage.id)
        end
      invalid_assoc_changeset ->
        {:error, invalid_assoc_changeset}
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
