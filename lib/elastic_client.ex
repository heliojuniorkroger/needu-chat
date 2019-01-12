defmodule NeeduChat.ElasticClient do
    @elastic_url "http://localhost:9200"

    def get(url) do
        response = "#{@elastic_url}#{url}" |> HTTPoison.get!

        response.body |> Poison.decode!
    end

    def post(url, body) do
        response = "#{@elastic_url}#{url}"
        |> HTTPoison.post!(body |> Poison.encode!, ["Content-Type": "application/json"])

        response.body |> Poison.decode!
    end

    def normalize(result) when is_list(result) do
        new_result = result |> Enum.reduce(fn item ->
            item["_source"] |> Map.merge(%{id: result["_id"]})
        end)

        new_result
    end

    def normalize(result) when is_map(result) do
        result["_source"] |> Map.merge(%{id: result["_id"]})
    end
end