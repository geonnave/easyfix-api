defmodule EasyFixApi.Emails do
  import Bamboo.Email

  alias EasyFixApi.Orders.Matcher
  alias EasyFixApi.{Orders, Mailer}

  def send_email_to_matching_garages(new_order) do
    new_order
    |> Matcher.list_garages_matching_order
    |> Enum.map(&new_order_email(&1, new_order))
    |> Enum.each(&Mailer.deliver_now/1)
  end

  def quoted_by_garages(customer) do
    # ec2_quote_url =  "http://#{url[:host]}"
    domain = Application.get_env(:easy_fix_api, :domain)
    customer_url =  "http://app.#{domain}/"

    new_email()
    |> to("#{customer.name} <#{customer.user.email}>")
    |> from("Easyfix <contato@easyfix.net.br>")
    |> subject("Seu Orçamento Easyfix chegou!")
    |> html_body("""
Olá #{customer.name}, boas notícas!<br>
<br>
As oficinas EasyFix já orçaram o seu pedido, e nós encontramos o melhor preço pra você.
Acesse o nosso app e confira: <a href="#{customer_url}" target="_blank">EasyFix App</a>.
    """)
  end

  def accepted_by_customer(order = %{customer: customer, accepted_quote: accepted_quote}) do
    accepted_quote = Orders.with_total_amount(accepted_quote)

    new_email()
    |> to("Easyfix <contato@easyfix.net.br>")
    |> from("Easyfix <contato@easyfix.net.br>")
    |> subject("Cliente clicou em 'comprar' orçamento")
    |> html_body("""
O seguinte cliente acaba de comprar um orçamento:<br>

Nome: #{customer.name}<br>
Telefone: #{customer.phone}<br>
Email: #{customer.user.email}<br><br>
<br>
Valor total do orçamento: #{Money.to_string(accepted_quote.total_amount)}
Valor total do orçamento (com taxa EasyFix): #{Money.to_string(Orders.add_customer_fee(accepted_quote).total_amount)}
    """)
  end

  def quoted_by_garages(customer) do
    # ec2_quote_url =  "http://#{url[:host]}"
    domain = Application.get_env(:easy_fix_api, :domain)
    customer_url =  "http://app.#{domain}/"

    new_email()
    |> to("#{customer.name} <#{customer.user.email}>")
    |> from("Easyfix <contato@easyfix.net.br>")
    |> subject("Seu Orçamento Easyfix chegou!")
    |> html_body("""
Olá #{customer.name}, boas notícas!<br>
<br>
As oficinas EasyFix já orçaram o seu pedido, e nós encontramos o melhor preço pra você.
Acesse o nosso app e confira: <a href="#{customer_url}" target="_blank">EasyFix App</a>.
    """)
  end

  def new_order_email(garage, order) do
    ec2_quote_url =  "http://ec2-18-221-115-152.us-east-2.compute.amazonaws.com:8080/#/orders/#{order.id}"

    new_email()
    |> to("#{garage.name} <#{garage.user.email}>")
    |> from("Easyfix <contato@easyfix.net.br>")
    |> subject("Novo Pedido Easyfix!")
    |> html_body("""
Olá #{garage.name}!<br>
<br>
Um cliente acaba de nos enviar um pedido. Ele certamente está ansioso para receber o seu orçamento.<br>
<br>
E aí, vamos orçar? <a href="#{ec2_quote_url}" target="_blank">Clique aqui</a> para abrir o painel de orçamento Easyfix.
    """)
  end

  def new_customer_email(customer) do
    [vehicle] = customer.vehicles

    new_email()
    |> to("Easyfix <contato@easyfix.net.br>")
    |> from("EasyFix System <contato@easyfix.net.br>")
    |> subject("Novo Cliente Easyfix!")
    |> html_body("""
Um novo cliente acaba de se cadastrar! Aqui estão seus dados:<br>
<br>
Nome: #{customer.name}<br>
Telefone: #{customer.phone}<br>
Email: #{customer.user.email}<br><br>
<br>
Veículo: #{vehicle.model.name}<br>
Ano: #{vehicle.model_year}<br>
    """)
  end
end