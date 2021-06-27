defmodule Engine do
  @moduledoc false
#  @endpoint "http://51.38.224.112:65001/blazegraph/sparql"
  @endpoint "https://query.wikidata.org/sparql"
  @default_limit 5
  @headers %{ "User-Agent" => "XBR/0.1 (https://www.mediawiki.org/wiki/User:Jorgeyp; id+wikidata@jorgeyp.com) hackney/1.6"}

  def query(queryString) do

    queryString
      |> SPARQL.Client.query(@endpoint, headers: @headers)
  end

  def search(queryString) do
    """
    prefix bds: <http://www.bigdata.com/rdf/search#>
    select ?s ?p ?o { ?o bds:search "#{queryString}*" . ?s ?p ?o . }
    LIMIT #{@default_limit}
    """
    |> SPARQL.Client.query(@endpoint, headers: @headers)
  end

  def searchSub(queryString) do
#    """
#    prefix bds: <http://www.bigdata.com/rdf/search#>
#    select ?s ?p ?o { ?o bds:search "#{queryString}*" . ?s ?p ?o . }
#    LIMIT #{@default_limit}
#    """

    """
    SELECT ?item ?itemLabel ?itemDescription WHERE {
      SERVICE wikibase:mwapi {
        bd:serviceParam wikibase:endpoint "www.wikidata.org";
          wikibase:api "EntitySearch";
          mwapi:search "#{queryString}";
          mwapi:language "en".
        ?item wikibase:apiOutputItem mwapi:item.
        bd:serviceParam wikibase:limit #{@default_limit} .
      }
      SERVICE wikibase:label {bd:serviceParam wikibase:language "en".}
      }
      LIMIT #{@default_limit}
    """
    |> SPARQL.Client.query(@endpoint, headers: @headers)
  end

  def searchPred(queryString, item_id) do
    IO.puts(["Search pred: ", queryString, item_id])
    """
    PREFIX wikibase: <http://wikiba.se/ontology#>
    SELECT distinct ?propertyName ?propertyLabel ?property ?itemLabel ?item ?predicateLabel ?predicate {
      VALUES (?subject) { (wd:#{item_id}) }
      ?subject ?predicate ?item .
      ?property wikibase:directClaim ?predicate .

      ?property rdfs:label ?propertyName .

      FILTER(lang(?propertyName) = 'en')
      FILTER regex(?propertyName, "#{queryString}", "i")

      SERVICE wikibase:label { bd:serviceParam wikibase:language "en" } .
    }
    LIMIT 1000
    """
    |> SPARQL.Client.query(@endpoint, headers: @headers)
  end

  def searchObj(queryString) do
    """
    prefix bds: <http://www.bigdata.com/rdf/search#>
    select ?s ?p ?o { ?o bds:search "#{queryString}*" . ?s ?p ?o . }
    LIMIT #{@default_limit}
    """
    |> SPARQL.Client.query(@endpoint, headers: @headers)
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

#    {:ok, response} =
#      Tesla.post(@endpoint, query, headers: [{"content-type", "application/sparql-update"}])

  end
end
