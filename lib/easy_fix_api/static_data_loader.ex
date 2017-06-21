defmodule EasyFixApi.StaticDataLoader do
  alias NimbleCSV.RFC4180, as: CSV

  def read_from_path_priv_repo(name) do
    Path.join([:code.priv_dir(:easy_fix_api), "repo", "static_data", name])
    |> File.read!
  end
  def prepare_csv(raw_csv), do: CSV.parse_string(raw_csv)

  def transform_vehicles_models(raw_csv) do
    {brands_to_models, _} =
      raw_csv
      |> prepare_csv()
      |> Enum.reduce({%{}, ""}, fn([brand, model], {acc, last_brand}) ->
      brand = if brand == "", do: last_brand, else: brand
      brand_models = Map.get(acc, brand, [])
      acc = put_in(acc, [brand], [model | brand_models])
      {acc, brand}
    end)
      brands_to_models
  end

  def transform_parts(raw_csv) do
    {parts, _, _} =
      raw_csv
      |> prepare_csv()
      |> Enum.reduce({[], "", ""}, fn(part, {acc, last_group, last_sub_group}) ->
        [group, sub_group, name, garage_type, _, repair_by_fixer, _, _, _] =
          part
          |> Enum.map(&String.capitalize/1)

        {group, sub_group, last_group, last_sub_group} =
          cond do
            group != "" && sub_group != "" ->
              {group, sub_group, group, sub_group}
            group != "" && sub_group == "" ->
              {group, "", group, ""}
            group == "" && sub_group == "" ->
              {last_group, last_sub_group, last_group, last_sub_group}
            group == "" && sub_group != "" ->
              {last_group, sub_group, last_group, sub_group}
          end

        part = %{group: group, sub_group: sub_group, name: name,
          garage_type: garage_type, repair_by_fixer: repair_by_fixer}
        acc = [part | acc]
        {acc, last_group, last_sub_group}
      end)

    parts
  end
end
