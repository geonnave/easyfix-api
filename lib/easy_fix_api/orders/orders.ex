defmodule EasyFixApi.Orders do
  @moduledoc """
  The boundary for the Orders system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.{Repo, Helpers}
  alias EasyFixApi.Parts.Part

  alias EasyFixApi.Orders.Diagnostic

  def list_diagnostics do
    Repo.all(Diagnostic)
    |> preload_all_nested_associations()
  end

  def get_diagnostic!(id) do
    Repo.get!(Diagnostic, id)
    |> preload_all_nested_associations()
  end

  def create_diagnostic(attrs \\ %{}) do
    with diagnostic_changeset = %{valid?: true} <- Diagnostic.create_changeset(attrs),
         diagnostic_assoc_changeset = %{valid?: true} <- Diagnostic.assoc_changeset(attrs),
         diagnostic_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(diagnostic_assoc_changeset) do

      parts =
        (diagnostic_assoc_attrs[:parts_ids] || [])
        |> Enum.map(&Repo.get(Part, &1))

      diagnostic_changeset
      |> put_assoc(:parts, parts)
      |> Repo.insert()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def delete_diagnostic(%Diagnostic{} = diagnostic) do
    Repo.delete(diagnostic)
  end

  defp preload_all_nested_associations(order_or_orders) do
    Repo.preload(order_or_orders, [parts: [part_sub_group: [part_group: :part_system]]])
  end

  alias EasyFixApi.Orders.Budget

  def list_budgets do
    Repo.all(Budget)
  end

  def get_budget!(id), do: Repo.get!(Budget, id)

  def create_budget(attrs \\ %{}) do
    %Budget{}
    |> Budget.changeset(attrs)
    |> Repo.insert()
  end

  def update_budget(%Budget{} = budget, attrs) do
    budget
    |> Budget.changeset(attrs)
    |> Repo.update()
  end

  def delete_budget(%Budget{} = budget) do
    Repo.delete(budget)
  end
end
