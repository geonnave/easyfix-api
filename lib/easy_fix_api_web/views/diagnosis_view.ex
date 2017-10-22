defmodule EasyFixApiWeb.DiagnosisView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.{DiagnosisView, DateView}

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
      state: diagnosis.state,
      comment: diagnosis.comment,
      expiration_date: DateView.render("iso_at_sao_paulo_tz", diagnosis.expiration_date),
      vehicle_mileage: diagnosis.vehicle_mileage,
      parts: render_many(diagnosis.diagnosis_parts, EasyFixApiWeb.DiagnosisPartView, "diagnosis_part.json"),
      vehicle: render_one(diagnosis.vehicle, EasyFixApiWeb.VehicleView, "vehicle.json"),
    }
  end
end
