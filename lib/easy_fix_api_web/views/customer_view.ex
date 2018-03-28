defmodule EasyFixApiWeb.CustomerView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.{CustomerView, CustomerVoucherView}

  def render("index.json", %{customers: customers}) do
    %{data: render_many(customers, CustomerView, "customer.json")}
  end

  def render("show.json", %{customer: customer}) do
    %{data: render_one(customer, CustomerView, "customer.json")}
  end
  def render("show_registration.json", %{customer: customer, jwt: jwt}) do
    %{data: render_one(customer, CustomerView, "customer.json"), jwt: jwt}
  end

  def render("customer.json", %{customer: customer}) do
    %{id: customer.id,
      name: customer.name,
      cpf: customer.cpf,
      email: customer.user.email,
      phone: customer.phone,
      accept_easyfix_policy: customer.accept_easyfix_policy,
      indication_code: customer.indication_code,
      available_vouchers: render_many(customer.available_vouchers, CustomerVoucherView, "customer_voucher.json"),
      address: render_one(customer.address, EasyFixApiWeb.AddressView, "address.json"),
      vehicles: render_many(customer.vehicles, EasyFixApiWeb.VehicleView, "vehicle.json"),
    }
  end

  def render("customer_contact.json", %{customer: customer}) do
    %{id: customer.id,
      name: customer.name,
      email: customer.user.email,
      phone: customer.phone,
      address: render_one(customer.address, EasyFixApiWeb.AddressView, "address.json"),
    }
  end
end
