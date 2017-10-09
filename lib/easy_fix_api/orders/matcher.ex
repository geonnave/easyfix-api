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
    parts = Enum.map(diagnosis.diagnosis_parts, & &1.part)
    parts_gcs = Enum.map(parts, & &1.garage_category)
    Enum.all?(parts_gcs, fn part_gc ->
      Enum.any?(garage_gcs, &part_and_garage_gc_match?(part_gc, &1))
    end)
  end

  def part_and_garage_gc_match?(part_gc, garage_gc) do
    part_gc.name == garage_gc.name ||
    part_gc.name == "Todas" ||
    garage_gc.name == "Todas" ||
    String.match?(part_gc.name, ~r/fluidos/i) && garage_gc.name == "Mecanica"
  end
end
