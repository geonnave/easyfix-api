defmodule EasyFixApi.Discover do
  use Timex
  require Logger

  NimbleCSV.define(TabCSV, separator: "\t")

  @weekdays 1..6
  @workinghours 8..18

  @one_hour 1000 * 60 * 60
  @fifteen_minutes 1000 * 60 * 15

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def next_message do
    send(__MODULE__, :next_message)
  end

  def stop do
    GenServer.cast __MODULE__, :stop
  end

  def init(_) do
    Process.send_after(self(), :next_message, 30_000)
    {:ok, %{}}
  end

  def handle_info(:next_message, state) do
    with true <- working_hour?(),
         :ok <- pop_and_send_email() do
      Process.send_after(self(), :next_message, compute_delay_for_next_message())
      {:noreply, state}
    else
      :stop ->
        {:noreply, state}
      false ->
        Process.send_after(self(), :next_message, compute_delay_for_next_message())
    end
  end

  def handle_cast(:stop, state) do
    {:noreply, state}
  end

  def working_hour? do
    now = DateTime.utc_now |> Timezone.convert("America/Sao_Paulo")
    Date.day_of_week(now) in @weekdays and now.hour in @workinghours
  end

  def compute_delay_for_next_message do
    @one_hour + (Enum.random(-@fifteen_minutes..@fifteen_minutes))
  end

  def setup(_divide_parts \\ 2) do
    [first | rest] =
      read("parts_call_direct.txt")
      |> String.split("\n")
      |> Enum.chunk_every(10)
    all_parts = [(first ++ List.last(rest)) | Enum.drop(rest, -1)]

    models = read("models.txt") |> TabCSV.parse_string
    emails =
      read("emails.txt")
      |> String.split("--\n")
      |> Enum.map(fn email ->
        [subject, body] = String.split(email, "\n", parts: 2)
        {subject, body}
      end)

    emails = for [_id, _name, _brand, model] <- models, parts <- all_parts do
      [{subject, body}] = Enum.take_random(emails, 1)

      body =
        body
        |> String.replace("<pecas>", serialize_parts(Enum.shuffle(parts)))
        |> String.replace("<carro>", serialize_model(model))

      %{
        subject: subject,
        body: body
      }
    end

    emails = emails |> Enum.shuffle |> Poison.encode!

    File.write(make_filename("emails_complete.json"), emails, [:write])
  end

  def serialize_parts(parts) do
    parts
    |> Enum.map(fn part ->
      "1\t#{part}\n"
    end)
    |> Enum.reduce(fn x, acc -> x <> acc end)
  end

  def serialize_model(model) do
    "#{model}"
  end

  def read(filename) do
    make_filename(filename)
    |> File.read!
  end

  def make_filename(filename) do
    Path.join(:code.priv_dir(:easy_fix_api), filename)
  end

  def pop_and_send_email do
    read("emails_complete.json")
    |> Poison.decode!
    |> case do
      [] ->
        Logger.warn("No more emails to send")
        :stop
      [email | rest] ->
        Logger.debug("Sending email. #{length(rest)} emails remaining...")
        File.write(make_filename("emails_complete.json"), Poison.encode!(rest), [:write])
        discover_price(email) |> EasyFixApi.Mailer.deliver_later()
        :ok
    end
  end

  import Bamboo.Email
  def discover_price(%{"subject" => subject, "body" => body}) do
    random_name = Enum.random(["Wilson", "Geovane", "Fábio", "Diego"])
    body = String.replace(body, "<nome>", random_name) |> String.replace("\n", "<br>")

    new_email()
    |> from("#{random_name} <contato@easyfix.net.br>")
    |> to("Mercado Car <telepreco.orcamento@mercadocar.com.br>")
    |> subject(subject)
    |> html_body(body)
  end
end
