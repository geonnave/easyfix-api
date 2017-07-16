defmodule EasyFixApi.Web.AddressView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Web.AddressView

  def render("index.json", %{addresses: addresses}) do
    %{data: render_many(addresses, AddressView, "address.json")}
  end

  def render("show.json", %{address: address}) do
    %{data: render_one(address, AddressView, "address.json")}
  end

  # TODO: decide wether to render city and state as nested or flat structures
  def render("address.json", %{address: address}) do
    %{id: address.id,
      postal_code: address.postal_code,
      address_line1: address.address_line1,
      address_line2: address.address_line2,
      neighborhood: address.neighborhood}
  end
end
