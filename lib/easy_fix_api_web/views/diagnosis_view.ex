defmodule EasyFixApiWeb.DiagnosisView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.DiagnosisView

  def render("index.json", %{diagnosis: diagnosis}) do
    %{data: render_many(diagnosis, DiagnosisView, "diagnosis.json")}
  end

  def render("show.json", %{diagnosis: diagnosis}) do
    %{data: render_one(diagnosis, DiagnosisView, "diagnosis.json")}
  end

  def render("diagnosis.json", %{diagnosis: diagnosis}) do
    %{id: diagnosis.id,
      accepts_used_parts: diagnosis.accepts_used_parts,
      need_tow_truck: diagnosis.need_tow_truck,
      status: diagnosis.status,
      comment: diagnosis.comment,
      expiration_date: diagnosis.expiration_date,
      parts: render_many(diagnosis.diagnosis_parts, EasyFixApiWeb.DiagnosisPartView, "diagnosis_part.json"),
      vehicle: render_one(diagnosis.vehicle, EasyFixApiWeb.VehicleView, "vehicle.json"),
    }
  end
end
