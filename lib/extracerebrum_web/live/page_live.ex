defmodule ExtracerebrumWeb.PageLive do
  use ExtracerebrumWeb, :live_view

  alias SPARQL.Query

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, results: [], sub: "", pred: "", obj: "", active_entity_index: 0)}
  end

  @impl true
  def handle_event("record", %{"triple" => triple}, socket) do

#    Engine.record(triple["s"])
    {:noreply, socket}
  end

  @impl true
  def handle_event("show_property", _value, socket) do
    IO.puts("SHOW PROPERTY")

    {:noreply, assign(socket, results: [], active_entity_index: 1)}
  end

  @impl true
  def handle_event("keyup", %{"key" => "Enter"}, socket) do
    IO.inspect(socket)
    {:noreply, assign(socket, results: [], active_entity_index: next_entity_index(socket.assigns))}
  end

  def handle_event("keyup", _key, socket) do
    IO.puts("KEY")
    {:noreply, socket}
  end

  @impl true
  def handle_event("explore-s", %{"entity" => entity, "label" => label}, socket) do
    IO.puts(["Entity: ", entity])
    IO.puts(["Label: ", label])

    {:noreply, assign(socket, results: [], sub: label, active_entity_index: 1, entity: entity)}
  end

  defp is_minimum_lenght?(term) do
    String.length(term) >= 3
  end

  def handle_sub(sub, socket) do
      IO.puts(["Handle sub: ", sub])

      if is_minimum_lenght?(sub) do
        case Engine.searchSub(sub) do
          {:ok, %Query.Result{} = queryResult} ->
            results = queryResult.results
                      |> Enum.map(fn result ->
              %{
                :id => result["item"] |> RDF.Term.value,
                :label => result["itemLabel"] |> RDF.Term.value,
                :desc => result["itemDescription"] |> RDF.Term.value
              }
            end)
            {:noreply, assign(socket, results: results, sub: sub)}

          {:error, reason} ->
            {:noreply, assign(socket, results: [])}
        end
      else
        {:noreply, assign(socket, results: [], sub: sub)}
      end
    end

#  def handle_sub(sub, socket) do
#    IO.puts(sub)
#    case Engine.search(sub) do
#      {:ok, %Query.Result{} = rdfResults} ->
#        results = rdfResults
#                  |> Query.Result.get(:o)
#                  |> Enum.map(fn(s) -> RDF.Term.value(s) end)
#        {:noreply, assign(socket, results: results, sub: sub)}
#
#      {:error, reason} ->
#        {:noreply, assign(socket, results: [])}
#    end
#  end

  def handle_pred(pred, socket) do
    IO.puts(["PRED: ", pred])

    item_id = socket.assigns.entity |> String.split("/") |> List.last

    IO.puts(["PRED ENTITY: ", item_id])

    if is_minimum_lenght?(pred) do
      case Engine.searchPred(pred, item_id) do
        {:ok, %Query.Result{} = queryResult} ->
          results = queryResult.results
                    |> Enum.map(fn result ->
            %{
              :label => result["propertyLabel"] |> RDF.Term.value,
              :id => result["item"] |> RDF.Term.value
            }
          end)
          IO.inspect(results)
          {:noreply, assign(socket, results: results, pred: pred)}

        {:error, reason} ->
          {:noreply, assign(socket, results: [])}
      end
    else
      {:noreply, assign(socket, results: [], pred: pred)}
    end
  end

  def handle_obj(obj, socket) do
    IO.puts(obj)

    if is_minimum_lenght?(obj) do
      case Engine.search(obj) do
        {:ok, %Query.Result{} = rdfResults} ->
          results = rdfResults
                    |> Query.Result.get(:o)
                    |> Enum.map(fn(s) -> RDF.Term.value(s) end)

          {:noreply, assign(socket, results: results, obj: obj)}
        {:error, reason} ->
          {:noreply, assign(socket, results: [])}
      end
    else
      {:noreply, assign(socket, results: [], obj: obj)}
    end
  end

  @impl true
  def handle_event("suggest", %{"_target" => target, "triple" => triple}, socket) do
      IO.puts("handle suggest")
      IO.puts(target)

      case target do
        ["triple", "s"] -> handle_sub(triple["s"], socket)
        ["triple", "p"] -> handle_pred(triple["p"], socket)
        ["triple", "o"] -> handle_obj(triple["o"], socket)
      end

#    case Engine.search(query) do
#      {:ok, %Query.Result{} = rdfResults} ->
#        results = rdfResults
#                  |> Query.Result.get(:o)
#                  |> Enum.map(fn(s) -> RDF.Term.value(s) end)
#
#        {:noreply, assign(socket, results: results, matches: [])}
#      {:error, reason} ->
#        {:noreply, assign(socket, results: [], matches: [])}
#    end

#    matches = search(query)
#    {:noreply, assign(socket, results: [], matches: matches, query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case Engine.query(query) do
      {:ok, %Query.Result{} = rdfResults} ->
        results = rdfResults
          |> Query.Result.get(:sub)
          |> Enum.map(fn(s) -> RDF.Term.value(s) end)
        IO.puts(results)
        {:noreply, assign(socket, results: results)}
      {:error, reason} -> IO.puts reason
    end
#    case search(query) do
#      %{^query => vsn} ->
#        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}
#
#      _ ->
#        {:noreply,
#         socket
#         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
#         |> assign(matches: %{}, query: query)}
#    end
  end

  defp search(query) do
    if not ExtracerebrumWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end

  defp next_entity_index(assigns) when assigns.active_entity_index < 3 do
    cond do
      String.length(assigns.sub) > 0  && String.length(assigns.pred) == 0 -> 1
      String.length(assigns.pred) > 0 -> 2
    end
  end
end
