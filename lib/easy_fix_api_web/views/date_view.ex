defmodule EasyFixApiWeb.DateView do
  # use EasyFixApiWeb, :view
  use Timex

  def render("iso_at_sao_paulo_tz", nil), do: nil
  def render("iso_at_sao_paulo_tz", datetime) do
    datetime
    |> Timezone.convert("America/Sao_Paulo")
    |> Timex.format!("{ISO:Extended}")
  end

  def render_human("iso_at_sao_paulo_tz", nil), do: nil
  def render_human("iso_at_sao_paulo_tz", datetime) do
    datetime
    |> Timezone.convert("America/Sao_Paulo")
    |> Timex.format!("{RFC1123}")
  end
end
