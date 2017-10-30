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
    |> Enum.filter(fn order = %{diagnosis: diagnosis} ->
      diagnosis_matches_garage_categories?(diagnosis, garage.garage_categories) &&
      (Timex.to_unix(order.inserted_at) >= Timex.to_unix(garage.inserted_at))
    end)
  end

  def diagnosis_matches_garage_categories?(diagnosis, garage_gcs) do
    diagnosis.diagnosis_parts
    |> Enum.map(& &1.part)
    |> Enum.all?(fn %{garage_category: part_gc, repair_by_fixer: repair_by_fixer} ->
      Enum.any?(garage_gcs, &part_matches_garage?(part_gc, &1)) ||
      Enum.any?(garage_gcs, &repair_by_fixer_matches_autonomous_garage?(repair_by_fixer, &1.name))
    end)
  end

  def repair_by_fixer_matches_autonomous_garage?(true, "Autônomo"), do: true
  def repair_by_fixer_matches_autonomous_garage?(_part, _garage_gc), do: false

  def part_matches_garage?(part_gc, garage_gc) do
    part_gc.name == garage_gc.name ||
    part_gc.name == "Todas" ||
    garage_gc.name == "Todas"
  end
end
