defmodule JumpTicketsWeb.TicketDoneController do
  use JumpTicketsWeb, :controller

  alias JumpTickets.{Repo, Ticket}
  alias JumpTickets.Ticket.DoneNotifier
  alias JumpTickets.External.Notion

  @doc """
  Handles a Notion webhook for when a ticket is marked as Done.

  Expects a JSON payload with the `page_id` key.
  """
  def notion_webhook(conn, %{"data" => %{"id" => page_id}}) do
    with %Ticket{} = ticket <- Notion.get_ticket_by_page_id(page_id),
         :ok <- DoneNotifier.notify_ticket_done(ticket) do
      json(conn, %{status: "ok", message: "Ticket done notification sent."})
    else
      err ->
        conn
        |> put_status(500)
        |> json(%{status: "error", error: inspect(err)})
    end
  end

  def notion_webhook(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{status: "error", error: "missing data.id in payload"})
  end
end
