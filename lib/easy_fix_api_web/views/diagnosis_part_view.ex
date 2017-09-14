defmodule EasyFixApiWeb.DiagnosisPartView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.DiagnosisPartView

  def render("index.json", %{diagnosis_parts: diagnosis_parts}) do
    %{data: render_many(diagnosis_parts, DiagnosisPartView, "diagnosis_part.json")}
  end

  def render("show.json", %{diagnosis_part: diagnosis_part}) do
    %{data: render_one(diagnosis_part, DiagnosisPartView, "diagnosis_part.json")}
  end

  def render("diagnosis_part.json", %{diagnosis_part: diagnosis_part}) do
    %{id: diagnosis_part.id,
      quantity: diagnosis_part.quantity,
      part: render_one(diagnosis_part.part, EasyFixApiWeb.PartView, "part.json"),
    }
  end
end
