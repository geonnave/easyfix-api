defmodule EasyFixApiWeb.CustomerEmailController do
  use EasyFixApiWeb, :controller
  alias EasyFixApi.{Accounts, Emails, Mailer}

  action_fallback EasyFixApiWeb.FallbackController

  def create(conn, %{"customer_id" => customer_id, "message" => message}) do
    message =
      Accounts.get_customer!(customer_id)
      |> Emails.Internal.customer_message(message)

    Mailer.deliver_later(message)

    json(conn, message)
  end
end
