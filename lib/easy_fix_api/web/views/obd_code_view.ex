defmodule EasyFixApi.Web.OBDCodeView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Web.OBDCodeView

  def render("index.json", %{obd_codes: obd_codes}) do
    %{data: render_many(obd_codes, OBDCodeView, "obd_code.json")}
  end

  def render("show.json", %{obd_code: obd_code}) do
    %{data: render_one(obd_code, OBDCodeView, "obd_code.json")}
  end

  def render("obd_code.json", %{obd_code: obd_code}) do
    %{id: obd_code.id,
      code: obd_code.code,
      description: obd_code.description}
  end
end
