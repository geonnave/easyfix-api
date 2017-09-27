defmodule EasyFixApiWeb.DateView do
  # use EasyFixApiWeb, :view
  use Timex

  def render("iso_at_sao_paulo_tz", nil), do: nil
  def render("iso_at_sao_paulo_tz", datetime) do
    datetime
    |> Timezone.convert("America/Sao_Paulo")
    |> Timex.format!("{ISO:Extended}")
  end
end
