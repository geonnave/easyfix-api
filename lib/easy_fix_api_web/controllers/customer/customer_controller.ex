defmodule EasyFixApiWeb.CustomerController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Accounts, Emails, Mailer}
  alias EasyFixApi.Accounts.Customer

  action_fallback EasyFixApiWeb.FallbackController
  plug Guardian.Plug.EnsureAuthenticated,
    [handler: EasyFixApiWeb.SessionController] when not action in [:create]

  def index(conn, _params) do
    customers = Accounts.list_customers()
    render(conn, "index.json", customers: customers)
  end

  def create(conn, %{"customer" => customer_params, "basic" => "true"}) do
    with {:ok, %Customer{} = customer} <- Accounts.create_basic_customer(customer_params) do
      handle_created_customer(conn, customer)
    end
  end
  def create(conn, %{"customer" => customer_params}) do
    with {:ok, %Customer{} = customer} <- Accounts.create_customer(customer_params) do
      handle_created_customer(conn, customer)
    end
  end
  defp handle_created_customer(conn, customer) do
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(customer.user, :token)

    Emails.Internal.new_customer(customer) |> Mailer.deliver_now
    Emails.Customer.welcome(customer) |> Mailer.deliver_now

    conn
    |> put_status(:created)
    |> put_resp_header("location", customer_path(conn, :show, customer))
    |> render("show_registration.json", customer: customer, jwt: jwt)
  end

  def show(conn, %{"id" => id}) do
    customer = Accounts.get_customer!(id)
    render(conn, "show.json", customer: customer)
  end

  def update(conn, %{"id" => id, "customer" => customer_params}) do
    customer = Accounts.get_customer!(id)

    with {:ok, %Customer{} = customer} <- Accounts.update_customer(customer, customer_params) do
      render(conn, "show.json", customer: customer)
    end
  end

  def delete(conn, %{"id" => id}) do
    customer = Accounts.get_customer!(id)
    with {:ok, %Customer{}} <- Accounts.delete_customer(customer) do
      send_resp(conn, :no_content, "")
    end
  end
end
