defmodule EasyFixApi.Emails do
  import Bamboo.Email

  alias EasyFixApi.Orders.Matcher
  alias EasyFixApi.{Orders, Mailer}

  def send_email_to_matching_garages(new_order) do
    new_order
    |> Matcher.list_garages_matching_order
    |> Enum.map(&new_order_email(&1, new_order))
    |> Enum.each(&Mailer.deliver_later/1)
  end

  def quoted_by_garages(order = %{customer: customer}) do
    domain = Application.get_env(:easy_fix_api, :domain)
    customer_url =  "http://app.#{domain}/"

    new_email()
    |> to("#{customer.name} <#{customer.user.email}>")
    |> from("EasyFix <contato@easyfix.net.br>")
    |> subject("Seu Orçamento Easyfix chegou!")
    |> html_body("""
Olá #{customer.name}, boas notícas!<br>
<br>
As oficinas e Fixers EasyFix já analisaram e orçaram o seu pedido \##{order.id}, 
e nós encontramos o melhor preço pra você.<br>
Acesse o nosso app e confira: <a href="#{customer_url}" target="_blank">EasyFix App</a>.<br>
Parabéns por esta conquista!<br>
<br><br><br>
EasyFix! Nós valorizamos sua mobilidade!
    """)
  end

  def accepted_by_customer(order = %{customer: customer, accepted_quote: accepted_quote}) do
    accepted_quote = Orders.with_total_amount(accepted_quote)

    new_email()
    |> to("Easyfix <contato@easyfix.net.br>")
    |> from("EasyFix <contato@easyfix.net.br>")
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

  def new_order_email(garage, order) do
    ec2_quote_url =  "http://ec2-18-221-115-152.us-east-2.compute.amazonaws.com:8080/#/orders/#{order.id}"

    new_email()
    |> to("#{garage.name} <#{garage.user.email}>")
    |> from("EasyFix <contato@easyfix.net.br>")
    |> subject("Novo Pedido Easyfix!")
    |> html_body("""
Olá #{garage.name}!<br>
<br>
Um cliente acaba de nos enviar o pedido \##{order.id}. Ele certamente está ansioso para receber o seu orçamento.<br>
<br>
E aí, vamos orçar? <a href="#{ec2_quote_url}" target="_blank">Clique aqui</a> para abrir o painel de orçamento Easyfix.
    """)
  end

  def new_order_email_to_easyfix(order = %{customer: customer}) do
    new_email()
    |> to("Easyfix <contato@easyfix.net.br>")
    |> from("EasyFix System <contato@easyfix.net.br>")
    |> subject("Novo Pedido Easyfix!")
    |> html_body("""
O cliente #{customer.name} acaba de fazer o pedido \##{order.id}! Aqui estão seus dados:<br>
<br>
Cliente ID: #{customer.id}<br>
Nome: #{customer.name}<br>
Telefone: #{customer.phone}<br>
Email: #{customer.user.email}<br><br>
<br>
    """)
  end

  def new_order_others_email_to_easyfix(order = %{customer: customer}) do
    new_email()
    |> to(["Easyfix <contato@easyfix.net.br>", "#{customer.name} <#{customer.user.email}>"])
    |> from("EasyFix System <contato@easyfix.net.br>")
    |> subject("Novo Pedido OUTROS Easyfix!")
    |> html_body("""
O cliente #{customer.name} acaba de fazer o pedido \##{order.id}! É um pedido do tipo "outros". Aqui estão seus dados:<br>
<br>
Cliente ID: #{customer.id}<br>
Nome: #{customer.name}<br>
Telefone: #{customer.phone}<br>
Email: #{customer.user.email}<br><br>
<br>
Veja o que ele escreveu sobre o reparo necessário:<br>
#{order.diagnosis.comment}
    """)
  end

  def new_customer_email_to_easyfix(customer) do
    [vehicle] = customer.vehicles

    new_email()
    |> to("Easyfix <contato@easyfix.net.br>")
    |> from("EasyFix System <contato@easyfix.net.br>")
    |> subject("Novo Cliente Easyfix!")
    |> html_body("""
Um novo cliente acaba de se cadastrar! Aqui estão seus dados:<br>
<br>
ID: #{customer.id}<br>
Nome: #{customer.name}<br>
Telefone: #{customer.phone}<br>
Email: #{customer.user.email}<br><br>
<br>
Veículo: #{vehicle.model.name}<br>
Ano: #{vehicle.model_year}<br>
    """)
  end

  def new_customer_email_to_customer(customer) do
    [vehicle] = customer.vehicles

    new_email()
    |> to("#{customer.name} <#{customer.user.email}>")
    |> from("EasyFix System <contato@easyfix.net.br>")
    |> subject("Novo Cliente Easyfix!")
    |> html_body("""
Olá #{customer.name}, bem vindo!<br>
<br>
Você é exatamente quem esperávamos!<br>
A partir de agora vai sentir o poder de conseguir para qualquer reparo 
em seu #{vehicle.model.name} a maior economia, qualidade, conforto e rapidez!!<br>
<br>
Somos o mecânico de confiança que tanto desejava e esperava!<br>
Compre via EasyFix e garanta vantagens!<br>
<br><br><br>
EasyFix! A peça que faltava para seu carro!<br>
    """)
  end
end