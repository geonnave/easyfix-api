defmodule EasyFixApi.Web.DiagnosticView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Web.DiagnosticView

  def render("index.json", %{diagnostics: diagnostics}) do
    %{data: render_many(diagnostics, DiagnosticView, "diagnostic.json")}
  end

  def render("show.json", %{diagnostic: diagnostic}) do
    %{data: render_one(diagnostic, DiagnosticView, "diagnostic.json")}
  end

  def render("diagnostic.json", %{diagnostic: diagnostic}) do
    %{id: diagnostic.id,
      accepts_used_parts: diagnostic.accepts_used_parts,
      need_tow_truck: diagnostic.need_tow_truck,
      status: diagnostic.status,
      comment: diagnostic.comment}
  end
end
