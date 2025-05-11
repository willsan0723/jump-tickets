defmodule Notionex.API.TeslaClient do
  @behaviour Notionex.API.Client
  alias Notionex.API.Request

  @bearer_token Application.compile_env!(:notionex, :bearer_token)
  @notion_version  Application.compile_env(:notionex, :notion_version, "2022-06-28")

  @impl true
  def request(%Request{} = req, _opts \\ []) do
    client = Tesla.client([
      {Tesla.Middleware.BaseUrl, ""},
      {Tesla.Middleware.Headers, [
         {"Authorization",  "Bearer " <> @bearer_token},
         {"Notion-Version", @notion_version},
         {"Content-Type",   "application/json"}
       ]},
      Tesla.Middleware.JSON
    ], {Tesla.Adapter.Finch, name: JumpTickets.Finch})

    case Tesla.request(client, method: req.method, url: req.url, body: req.body, query: req.params) do
      {:ok, %Tesla.Env{status: sc, body: body}} when sc in 200..299 ->
        {:ok, body}

      {:ok, %Tesla.Env{} = err_env} ->
        {:error, "Notion API error (#{err_env.status}): #{inspect(err_env.body)}"}

      {:error, reason} ->
        {:error, inspect(reason)}
    end
  end

  @impl true
  def request!(request, opts \\ []) do
    case request(request, opts) do
      {:ok, resp} -> resp
      {:error, err} -> raise "Notionex.TeslaClient error: #{err}"
    end
  end
end