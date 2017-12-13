defmodule EasyFixApi.CustomerNotifications do
  alias EasyFixApi.{Emails, Mailer}

  @sms_api Application.get_env(:easy_fix_api, :sms_api)

  defmodule SMS do
    def new_best_quote_arrived(order) do
      """
      Novo preço na área! Um orçamento para seu pedido \##{order.id} acaba de chegar! Acesse o app e confira ;)
      """
    end
    def order_was_quoted_by_garages(order) do
      """
      Boas notícias! A EasyFix concluiu a busca pelo melhor orçamento para o pedido \##{order.id}! Acesse o app e aproveite ;)
      """
    end
  end

  def new_best_quote_arrived(order, opts \\ [:email, :sms]) do
    cond do
      :sms in opts ->
        %{customer: %{phone: phone}} = order

        SMS.new_best_quote_arrived(order)
        |> @sms_api.send_sms(phone)
    end
  end

  def order_was_quoted_by_garages(order, opts \\ [:email, :sms]) do
    cond do
      :sms in opts ->
        %{customer: %{phone: phone}} = order

        SMS.order_was_quoted_by_garages(order)
        |> @sms_api.send_sms(phone)
      :email in opts ->
        Emails.Customer.order_was_quoted_by_garages(order)
        |> Mailer.deliver_later
    end
  end
end

defmodule EasyFixApi.GarageNotifications do
  # def multicast_new_order_call_direct(garage, new_order, opts \\ [:email, :websocket]) do
  # end

  # def new_quote_to_beat(new_order, opts \\ [:email, :websocket]) do
  # end

  # def new_order_to_quote(order = %{customer: customer}) do
  # end
end
