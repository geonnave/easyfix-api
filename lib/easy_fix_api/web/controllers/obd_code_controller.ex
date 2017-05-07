defmodule EasyFixApi.Web.OBDCodeController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.OBDCodes
  alias EasyFixApi.OBDCodes.OBDCode

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    obd_codes = OBDCodes.list_obd_codes()
    render(conn, "index.json", obd_codes: obd_codes)
  end

  def create(conn, %{"obd_code" => obd_code_params}) do
    with {:ok, %OBDCode{} = obd_code} <- OBDCodes.create_obd_code(obd_code_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", obd_code_path(conn, :show, obd_code))
      |> render("show.json", obd_code: obd_code)
    end
  end

  def show(conn, %{"id" => id}) do
    obd_code = OBDCodes.get_obd_code!(id)
    render(conn, "show.json", obd_code: obd_code)
  end

  def update(conn, %{"id" => id, "obd_code" => obd_code_params}) do
    obd_code = OBDCodes.get_obd_code!(id)

    with {:ok, %OBDCode{} = obd_code} <- OBDCodes.update_obd_code(obd_code, obd_code_params) do
      render(conn, "show.json", obd_code: obd_code)
    end
  end

  def delete(conn, %{"id" => id}) do
    obd_code = OBDCodes.get_obd_code!(id)
    with {:ok, %OBDCode{}} <- OBDCodes.delete_obd_code(obd_code) do
      send_resp(conn, :no_content, "")
    end
  end
end
