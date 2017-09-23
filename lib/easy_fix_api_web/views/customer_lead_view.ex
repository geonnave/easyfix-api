defmodule EasyFixApiWeb.CustomerLeadView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.CustomerLeadView

  def render("index.json", %{customer_leads: customer_leads}) do
    %{data: render_many(customer_leads, CustomerLeadView, "customer_lead.json")}
  end

  def render("show.json", %{customer_lead: customer_lead}) do
    %{data: render_one(customer_lead, CustomerLeadView, "customer_lead.json")}
  end

  def render("customer_lead.json", %{customer_lead: customer_lead}) do
    %{id: customer_lead.id,
      name: customer_lead.name,
      email: customer_lead.email,
      phone: customer_lead.phone,
      garage_id: customer_lead.garage_id,
      car: %{
        model: customer_lead.car.model,
        brand: customer_lead.car.brand,
        year: customer_lead.car.year,
      },
      address: %{
        city: customer_lead.address.city,
        neighborhood: customer_lead.address.neighborhood,
      }
    }
  end
end
