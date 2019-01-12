defmodule NeeduChat.Conversations do
    def handle(data) do
        message = create_message(%{
            content: data["content"],
            sentAt: Timex.now,
            conversation: find(data["author"], data["recipient"]),
            sentBy: data["author"]
        })
        |> NeeduChat.ElasticClient.normalize
        |> Poison.encode!

        %{
            headings: %{en: "Nova mensagem"},
            contents: %{en: data["content"]},
            filters: [%{
                field: "tag",
                key: "userId",
                relation: "=",
                value: data["recipient"]
            }]
        } |> NeeduChat.OneSignal.send_notification

        %{
            headings: %{en: "Nova mensagem"},
            contents: %{en: data["content"]},
            filters: [%{
                field: "tag",
                key: "userId",
                relation: "=",
                value: data["author"]
            }]
        } |> NeeduChat.OneSignal.send_notification

        message
    end

    defp create(author, recipient) do
        response = "/conversations/conversation"
        |> NeeduChat.ElasticClient.post(%{
            author: author,
            recipient: recipient,
            createdAt: Timex.now
        })

        response
    end

    def create_message(message) do
        response = "/messages/message"
        |> NeeduChat.ElasticClient.post(message)

        response = "/messages/message/#{response["_id"]}"
        |> NeeduChat.ElasticClient.get

        response
    end

    defp find(author, recipient) do
        response = "/conversations/conversation/_search"
        |> NeeduChat.ElasticClient.post(%{
            query: %{
                bool: %{
                    must: [
                        %{
                            multi_match: %{
                                query: author,
                                fields: ["author", "recipient"]
                            }
                        },
                        %{
                            multi_match: %{
                                query: recipient,
                                fields: ["author", "recipient"]
                            }
                        }
                    ]
                }
            }
        })

        case length(response["hits"]["hits"]) do
            0 ->
                response = create(author, recipient)
                response["_id"]
            1 ->
                List.first(response["hits"]["hits"])["_id"]
        end
    end
end