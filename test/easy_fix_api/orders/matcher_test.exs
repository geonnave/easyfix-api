defmodule EasyFixApi.OrdersMatcherTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Orders
  alias EasyFixApi.Parts.GarageCategory
  alias EasyFixApi.Orders.Matcher

  setup do
    gcs = %{
      mecanica: create_gc("Mecanica"),
      vidros: create_gc("Vidros"),
      todas: create_gc("Todas"),
      fluidos: create_gc("Fluidos"),
    }
    diag_parts = %{
      mecanica1: create_diag_part("mecanica1", gcs[:mecanica]),
      vidros1: create_diag_part("vidros1", gcs[:vidros]),
      todas1: create_diag_part("todas1", gcs[:todas]),
      fluidos1: create_diag_part("fluidos1", gcs[:fluidos]),
    }

    {:ok, %{gcs: gcs, diag_parts: diag_parts}}
  end

  describe "part_and_garage_gc_match?" do
    test "match same name", %{gcs: gcs, diag_parts: diag_parts} do
      assert Matcher.part_and_garage_gc_match?(gcs[:vidros], diag_parts[:vidros1].part.garage_category)

      refute Matcher.part_and_garage_gc_match?(gcs[:vidros], diag_parts[:mecanica1].part.garage_category)
      refute Matcher.part_and_garage_gc_match?(gcs[:mecanica], diag_parts[:vidros1].part.garage_category)
    end

    test "match part garage_category 'Todas'", %{gcs: gcs, diag_parts: diag_parts} do
      assert Matcher.part_and_garage_gc_match?(gcs[:todas], diag_parts[:vidros1].part.garage_category)
      assert Matcher.part_and_garage_gc_match?(gcs[:todas], diag_parts[:mecanica1].part.garage_category)
    end

    test "part garage_category 'Fluidos' also matches with garage garage_category 'Mecanica'", %{gcs: gcs, diag_parts: diag_parts} do
      assert Matcher.part_and_garage_gc_match?(gcs[:mecanica], diag_parts[:mecanica1].part.garage_category)
      assert Matcher.part_and_garage_gc_match?(gcs[:fluidos], diag_parts[:mecanica1].part.garage_category)

      refute Matcher.part_and_garage_gc_match?(gcs[:vidros], diag_parts[:mecanica1].part.garage_category)
    end

    test "part with repair_by_fixer = true matches with garage garage_category 'Autonomo'" do
      # TODO
    end
  end

  describe "test diagnosis_matches_garage_categories?" do
    test "match with vidros", %{gcs: gcs, diag_parts: diag_parts} do
      diagnosis =
        build(:diagnosis)
        |> with_diagnosis_parts([diag_parts[:vidros1]])
        |> insert

      assert Matcher.diagnosis_matches_garage_categories?(diagnosis, [gcs[:vidros]])
      assert Matcher.diagnosis_matches_garage_categories?(diagnosis, [gcs[:vidros], gcs[:mecanica]])

      refute Matcher.diagnosis_matches_garage_categories?(diagnosis, [gcs[:mecanica]])
    end
  end

  defp create_gc(name) do
    build(:garage_category)
    |> with_name(name)
    |> insert
  end
  defp create_diag_part(name, gc) do
    part =
      build(:part)
      |> with_name(name)
      |> with_category(gc)

    build(:diagnosis_part)
    |> with_part(part)
    |> insert
  end
end
