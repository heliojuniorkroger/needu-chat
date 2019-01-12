defmodule NeeduChat do
    def listen(client) do
        case client |> Socket.Web.recv! do
            {:text, data} ->
                message = data
                |> Poison.decode!
                |> NeeduChat.Conversations.handle
                client |> Socket.Web.send!({:text, message})
                client |> listen
            _ ->
                :ok
        end
    end

    def start(_type, _args) do
        server = Socket.Web.listen! 9090

        client = server |> Socket.Web.accept!
        client |> Socket.Web.accept!
        client |> listen

        Supervisor.start_link([], strategy: :one_for_one)
    end
end