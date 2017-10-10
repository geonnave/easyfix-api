defmodule EasyFixApi.Orders.Matcher do
  alias EasyFixApi.{Orders, Accounts}

  def list_garages_matching_order(%{diagnosis: diagnosis}) do
    Accounts.list_garages
    |> Enum.filter(fn garage ->
      diagnosis_matches_garage_categories?(diagnosis, garage.garage_categories)
    end)
  end

  def list_orders_matching_garage(garage) do
    Orders.list_orders
    |> Enum.filter(fn %{diagnosis: diagnosis} ->
      diagnosis_matches_garage_categories?(diagnosis, garage.garage_categories)
    end)
  end

  def diagnosis_matches_garage_categories?(diagnosis, garage_gcs) do
    diagnosis.diagnosis_parts
    |> Enum.map(& &1.part)
    |> Enum.all?(fn %{garage_category: part_gc, repair_by_fixer: repair_by_fixer} ->
      Enum.any?(garage_gcs, &part_and_garage_gc_match?(part_gc, &1)) ||
      Enum.any?(garage_gcs, &part_and_autonomous_garage_match?(repair_by_fixer, &1))
    end)
  end

  def part_and_autonomous_garage_match?(true, "Autonomo"), do: true
  def part_and_autonomous_garage_match?(_part, _garage_gc), do: false

  def part_and_garage_gc_match?(part_gc, garage_gc) do
    part_gc.name == garage_gc.name ||
    part_gc.name == "Todas" ||
    garage_gc.name == "Todas" ||
    String.match?(part_gc.name, ~r/fluidos/i) && garage_gc.name == "Mecanica"
  end
end
