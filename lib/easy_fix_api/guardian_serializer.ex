defmodule EasyFixApi.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias EasyFixApi.Repo
  alias EasyFixApi.Accounts.User

  def for_token(%User{id: id}), do: {:ok, "User:#{id}"}
  def for_token(_), do: {:error, "Invalid user"}

  def from_token("User:" <> id), do: {:ok, Repo.get(User, String.to_integer(id))}
  def from_token(_), do: {:error, "Invalid user"}

end