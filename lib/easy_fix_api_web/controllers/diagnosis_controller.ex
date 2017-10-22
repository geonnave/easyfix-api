defmodule EasyFixApiWeb.DiagnosisController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Orders
  alias EasyFixApi.Orders.Diagnosis

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params) do
    diagnosis = Orders.list_diagnosis()
    render(conn, "index.json", diagnosis: diagnosis)
  end

  def create(conn, %{"diagnosis" => diagnosis_params}) do
    with {:ok, %Diagnosis{} = diagnosis} <- Orders.create_diagnosis(diagnosis_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", diagnosis_path(conn, :show, diagnosis))
      |> render("show.json", diagnosis: diagnosis)
    end
  end

  def update(conn, %{"id" => id, "diagnosis" => diagnosis_params}) do
    diagnosis = Orders.get_diagnosis!(id)
    with {:ok, %Diagnosis{} = diagnosis} <- Orders.update_diagnosis(diagnosis, diagnosis_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", diagnosis_path(conn, :show, diagnosis))
      |> render("show.json", diagnosis: diagnosis)
    end
  end

  def show(conn, %{"id" => id}) do
    diagnosis = Orders.get_diagnosis!(id)
    render(conn, "show.json", diagnosis: diagnosis)
  end

  def delete(conn, %{"id" => id}) do
    diagnosis = Orders.get_diagnosis!(id)
    with {:ok, %Diagnosis{}} <- Orders.delete_diagnosis(diagnosis) do
      send_resp(conn, :no_content, "")
    end
  end
end
