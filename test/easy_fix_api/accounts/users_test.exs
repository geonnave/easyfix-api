defmodule EasyFixApi.AccountsTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Accounts
  alias EasyFixApi.Accounts.User

  @create_attrs %{email: "some@email.com", password: "some password"}
  @update_attrs %{email: "some@updated_email.com", password: "some updated password"}
  @invalid_attrs %{email: nil, password: nil}

  def fixture(:user, attrs \\ @create_attrs) do
    {:ok, user} = Accounts.create_user(attrs)
    # %{user | password: nil}
    user
  end

  test "list_users/1 returns all users" do
    user = fixture(:user)
    assert Accounts.list_users() == [user]
  end

  test "get_user! returns the user with given id" do
    user = fixture(:user)
    assert Accounts.get_user!(user.id) == user
  end

  test "create_user/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = Accounts.create_user(@create_attrs)
    assert user.email == "some@email.com"
  end

  test "create_user/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
  end

  test "update_user/2 with valid data updates the user" do
    user = fixture(:user)
    assert {:ok, user} = Accounts.update_user(user, @update_attrs)
    assert %User{} = user
    assert user.email == "some@updated_email.com"
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = fixture(:user)
    assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    assert user == Accounts.get_user!(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = fixture(:user)
    assert {:ok, %User{}} = Accounts.delete_user(user)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
  end

  test "User.changeset/2 will validate emails" do
    refute User.changeset(%User{}, %{email: "email"}).valid?
    refute User.changeset(%User{}, %{email: "email.com"}).valid?
    refute User.changeset(%User{}, %{email: "@email.com"}).valid?
    refute User.changeset(%User{}, %{email: "@email"}).valid?

    assert User.changeset(%User{}, %{email: "Some@email.Com"}).valid?
    assert User.changeset(%User{}, %{email: "some@email.com"}).valid?
  end

  test "User.process_email/2 will lowercase emails" do
    email = "Some@email.Com"
    assert "some@email.com" == User.process_email(email)
  end

  test "User.changeset/2 will trim emails" do
    email = " some@email.com  "
    assert "some@email.com" == User.process_email(email)
  end
end
