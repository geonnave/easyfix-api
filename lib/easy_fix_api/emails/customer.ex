defmodule EasyFixApi.Emails.Customer do
  import Bamboo.Email, except: [new_email: 1]

  alias EasyFixApiWeb.EmailCustomerView

  def new_email(customer) do
    Bamboo.Email.new_email()
    |> from("EasyFix <contato@easyfix.net.br>")
    |> to("#{customer.name} <#{customer.user.email}>")
  end

  def welcome(customer) do
    [vehicle] = customer.vehicles
    assigns = %{customer: customer, vehicle: vehicle}
    content = Phoenix.View.render_to_string(EmailCustomerView, "welcome.html", assigns)

    customer
    |> new_email()
    |> subject("Você acaba de ganhar um fiel amigo para seu carro! A EasyFix! 😊")
    |> html_body(content)
  end

  def new_order_call_direct(order = %{customer: customer}) do
    [vehicle] = customer.vehicles
    assigns = %{order: order, customer: customer, vehicle: vehicle}
    content = Phoenix.View.render_to_string(EmailCustomerView, "new_order_call_direct.html", assigns)

    customer
    |> new_email()
    |> subject("Seu pedido EasyFix já está em curso e os orçamentos estão chegando! 😊")
    |> html_body(content)
  end

  def new_order_call_fixer(order = %{customer: customer}) do
    [vehicle] = customer.vehicles
    assigns = %{order: order, customer: customer, vehicle: vehicle}
    content = Phoenix.View.render_to_string(EmailCustomerView, "new_order_call_fixer.html", assigns)

    customer
    |> new_email()
    |> subject("Seu pedido EasyFix já está em curso! 😊")
    |> html_body(content)
  end

  def first_quote_arrived(order = %{customer: customer}) do
    [vehicle] = customer.vehicles
    assigns = %{order: order, customer: customer, vehicle: vehicle}
    content = Phoenix.View.render_to_string(EmailCustomerView, "first_quote_arrived.html", assigns)

    customer
    |> new_email()
    |> subject("EasyFix é rapidez! Já chegou um primeiro orçamento! 😊")
    |> html_body(content)
  end

  def new_best_quote_arrived(order = %{customer: customer}) do
    [vehicle] = customer.vehicles
    assigns = %{order: order, customer: customer, vehicle: vehicle}
    content = Phoenix.View.render_to_string(EmailCustomerView, "new_best_quote_arrived.html", assigns)

    customer
    |> new_email()
    |> subject("EasyFix é melhorar preço sem parar! Chegou um valor ainda melhor 😊")
    |> html_body(content)
  end

  def order_was_quoted_by_garages(order = %{customer: customer}) do
    domain = Application.get_env(:easy_fix_api, :domain)
    customer_url =  "http://app.#{domain}/"
    [vehicle] = customer.vehicles
    assigns = %{customer: customer, vehicle: vehicle, order: order, customer_url: customer_url}
    content = Phoenix.View.render_to_string(EmailCustomerView, "order_was_quoted_by_garages.html", assigns)

    customer
    |> new_email()
    |> subject("Surpresa boa da EasyFix! Concluímos a busca pelo melhor orçamento! 😊")
    |> html_body(content)
  end

  def purchase_confirmation(order = %{customer: customer}) do
    assigns = %{customer: customer, order: order}
    content = Phoenix.View.render_to_string(EmailCustomerView, "purchase_confirmation.html", assigns)

    customer
    |> new_email()
    |> subject("Confirmação de interesse de compra EasyFix")
    |> html_body(content)
  end
end
