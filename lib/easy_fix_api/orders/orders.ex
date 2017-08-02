defmodule EasyFixApi.Orders do
  @moduledoc """
  The boundary for the Orders system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.Repo

  alias EasyFixApi.Orders.Diagnostic

  def list_diagnostics do
    Repo.all(Diagnostic)
  end

  def get_diagnostic!(id), do: Repo.get!(Diagnostic, id)

  def create_diagnostic(attrs \\ %{}) do
    %Diagnostic{}
    |> Diagnostic.changeset(attrs)
    |> Repo.insert()
  end

  def delete_diagnostic(%Diagnostic{} = diagnostic) do
    Repo.delete(diagnostic)
  end
end
