defmodule EasyFixApi.GuardianSerializerTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.{Repo, GuardianSerializer}
  alias EasyFixApi.Accounts.User

  setup_all do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EasyFixApi.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(EasyFixApi.Repo, {:shared, self()})

    attrs = %{email: "email@example.com", password: "password"}
    user = User.registration_changeset(%User{}, attrs) |> Repo.insert!

    {:ok, user: user}
  end

  test "generates token for valid user", %{user: user} do
    assert {:ok, _} = GuardianSerializer.for_token(user)
  end

  test "generates error for invalid user", %{} do
    assert {:error, "Invalid user"} = GuardianSerializer.for_token(%{})
  end

  test "finds user from valid token", %{user: user} do
    {:ok, token} = GuardianSerializer.for_token(user)
    assert {:ok, _} = GuardianSerializer.from_token(token)
  end

  test "doesn't find user from invalid token", %{} do
    assert {:error, "Invalid user"} = GuardianSerializer.from_token("bad")
  end
end