defmodule EasyFixApiWeb.CustomerLeadController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Accounts
  alias EasyFixApi.Accounts.CustomerLead

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params) do
    customer_leads = Accounts.list_customer_leads()
    render(conn, "index.json", customer_leads: customer_leads)
  end

  def create(conn, %{"customer_lead" => customer_lead_params}) do
    with {:ok, %CustomerLead{} = customer_lead} <- Accounts.create_customer_lead(customer_lead_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", customer_lead_path(conn, :show, customer_lead))
      |> render("show.json", customer_lead: customer_lead)
    end
  end

  def show(conn, %{"id" => id}) do
    customer_lead = Accounts.get_customer_lead!(id)
    render(conn, "show.json", customer_lead: customer_lead)
  end

  def update(conn, %{"id" => id, "customer_lead" => customer_lead_params}) do
    customer_lead = Accounts.get_customer_lead!(id)

    with {:ok, %CustomerLead{} = customer_lead} <- Accounts.update_customer_lead(customer_lead, customer_lead_params) do
      render(conn, "show.json", customer_lead: customer_lead)
    end
  end

  def delete(conn, %{"id" => id}) do
    customer_lead = Accounts.get_customer_lead!(id)
    with {:ok, %CustomerLead{}} <- Accounts.delete_customer_lead(customer_lead) do
      send_resp(conn, :no_content, "")
    end
  end
end
