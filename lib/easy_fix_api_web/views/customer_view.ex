defmodule EasyFixApiWeb.CustomerView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.CustomerView

  def render("index.json", %{customers: customers}) do
    %{data: render_many(customers, CustomerView, "customer.json")}
  end

  def render("show.json", %{customer: customer}) do
    %{data: render_one(customer, CustomerView, "customer.json")}
  end

  def render("customer.json", %{customer: customer}) do
    %{id: customer.id,
      name: customer.name,
      cpf: customer.cpf,
      email: customer.user.email,
      phone: customer.phone,
      accept_easyfix_policy: customer.accept_easyfix_policy,
      bank_account: render_one(customer.bank_account, EasyFixApiWeb.BankAccountView, "bank_account.json"),
      address: render_one(customer.address, EasyFixApiWeb.AddressView, "address.json"),
      vehicles: render_many(customer.vehicles, EasyFixApiWeb.VehicleView, "vehicle.json"),
    }
  end
end
