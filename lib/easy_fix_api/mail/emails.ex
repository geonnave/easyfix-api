defmodule EasyFixApi.Emails do
  import Bamboo.Email

  alias EasyFixApi.Orders.Matcher
  alias EasyFixApi.Mailer

  @url Application.get_env(:easy_fix_api, EasyFixApiWeb.Endpoint)[:url]

  def send_email_to_matching_garages(new_order) do
    new_order
    |> Matcher.list_garages_matching_order
    |> Enum.map(&new_order_email(&1, new_order))
    |> Enum.each(&Mailer.deliver_now/1)
  end

  def new_order_email(garage, order) do
    ec2_quote_url =  "http://#{@url[:host]}:8080/#/orders/#{order.id}"

    new_email()
    |> to("#{garage.name} <#{garage.user.email}>")
    |> from("Easyfix <contato@easyfix.net.br>")
    |> subject("Novo Pedido Easyfix!")
    |> html_body("""
Olá #{garage.name}!
<br><br>
Um cliente acaba de nos enviar um pedido. Ele certamente está ansioso para receber o seu orçamento.
<br><br>
E aí, vamos orçar? <a href="#{ec2_quote_url}">Clique aqui</a> para abrir o painel de orçamento Easyfix.
    """)
  end

  def new_customer_email(customer) do
    [vehicle] = customer.vehicles

    new_email()
    |> to("Easyfix <contato@easyfix.net.br>")
    |> from("EasyFix System <contato@easyfix.net.br>")
    |> subject("Novo Cliente Easyfix!")
    |> html_body("""
Um novo cliente acaba de se cadastrar! Aqui estão seus dados:

Nome: #{customer.name}
Telefone: #{customer.phone}
Email: #{customer.user.email}

Veículo: #{vehicle.model.name}
Ano: #{vehicle.model_year}
    """)
  end
end