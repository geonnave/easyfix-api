defmodule EasyFixApi.Parts.CallDirect do
  @call_direct_part_names [
    {"Pneu", "pneu"},
    {"Freios", "pastilha.*freio|discos de freio|conjunto.*sapatas.*freio"},
    {"Bateria", "bateria 12v"},
    {"Lâmpadas", "lâmpada|pisca|break light"},
    {"Troca de óleo", "óleo de motor|filtro de óleo"},
    {"Retrovisores", "retrovisor"},
    {"Limpador de Parabrisa", "((brucutu|palheta).*parabrisa)|((palheta|haste|esguicho).*traseiro)"},
    {"Vidros", "vidro"},
    {"Alinhamento, Balanceamento e Cambagem", "alinhamento|balanceamento|cambagem"},
    {"Filtros", "elemento filtro de ar"},
    {"Embreagem", "kit.*embreagem"},
    {"Suspensão", "(^amortecedor.*(dianteiro|traseiro))|(mola.*suspensão)|(batente.*torre.*amort.*(direit|esquerd))|(guarda.*pó.*dianteiro)|(bieleta.*estabilizadora.*(direita|esquerda))"},
  ]

  def filter_parts_call_direct(parts, names_substrings \\ @call_direct_part_names) do
    names_substrings
    |> Enum.map(fn {title, name_substring} ->
      {title, filter_parts_matching(parts, name_substring)}
    end)
  end

  def filter_parts_matching(parts, name_substring) do
    parts
    |> Enum.filter(fn part ->
      part_matches_name_substring?(part, name_substring)
    end)
  end

  def part_matches_name_substring?(%{name: nil}, _name_substring), do: false
  def part_matches_name_substring?(part, "vidro") do
    String.downcase(part.name) =~ ~r/vidro/i &&
    part_matches_exclude_substring?(part, ~r/palheta|limpador|borracha|mecanismo|máquina|guarnição|canaleta|mangueira|esguicho|botao|levantador/i)
  end
  def part_matches_name_substring?(part, "retrovisor") do
    String.downcase(part.name) =~ ~r/retrovisor/i &&
    part_matches_exclude_substring?(part, ~r/interno|lâmpada/i)
  end
  def part_matches_name_substring?(part, "lâmpada|pisca|break light" = name_substring) do
    String.downcase(part.name) =~ ~r/#{name_substring}/i &&
    part_matches_exclude_substring?(part, ~r/pisca.*retrovisor/i)
  end
  def part_matches_name_substring?(part, name_substring) do
    String.downcase(part.name) =~ ~r/#{String.downcase(name_substring)}/i
  end

  def part_matches_exclude_substring?(part, exclude_substrings) do
    !(String.downcase(part.name) =~ exclude_substrings)
  end
end