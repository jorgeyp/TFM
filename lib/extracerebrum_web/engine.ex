defmodule Engine do
  @moduledoc false
  @endpoint "http://vps300982.ovh.net:9999/blazegraph/sparql"

  def query(queryString) do
    queryString
      |> SPARQL.Client.query(@endpoint)
  end

  def search(queryString) do
    """
    prefix bds: <http://www.bigdata.com/rdf/search#>
    select ?s ?p ?o { ?o bds:search "#{queryString}*" . ?s ?p ?o . }
    """
    |> SPARQL.Client.query(@endpoint)
  end

  def searchSub(queryString) do
    """
    prefix bds: <http://www.bigdata.com/rdf/search#>
    select ?s ?p ?o { ?o bds:search "#{queryString}*" . ?s ?p ?o . }
    """
    |> SPARQL.Client.query(@endpoint)
  end

  def searchPred(queryString) do
    """
    prefix bds: <http://www.bigdata.com/rdf/search#>
    select ?s ?p ?o { ?o bds:search "#{queryString}*" . ?s ?p ?o . }
    """
    |> SPARQL.Client.query(@endpoint)
  end

  def searchObj(queryString) do
    """
    prefix bds: <http://www.bigdata.com/rdf/search#>
    select ?s ?p ?o { ?o bds:search "#{queryString}*" . ?s ?p ?o . }
    """
    |> SPARQL.Client.query(@endpoint)
  end

  def record(concept) do
    query = """
    PREFIX : <http://extracerebrum.xyz>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

    INSERT DATA
    {
      <urn:uuid:#{UUID.uuid4()}>  a skos:Concept ;
                                  skos:prefLabel "#{concept}" .
    }
    """
    IO.puts(query)

    {:ok, response} =
      Tesla.post(@endpoint, query, headers: [{"content-type", "application/sparql-update"}])

  end
end
