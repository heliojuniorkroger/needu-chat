defmodule NeeduChat.OneSignal do
    @app_id "2b21114d-b2d6-4884-a6e6-3bd6a3d86bf8"
    @key "Y2VkZWY2NTktYjhhOS00MjA2LWI4N2UtY2NhN2ZkMGMwN2M2"

    def send_notification(notification) do
        body = notification |> Map.merge(%{app_id: @app_id})
        response = "https://onesignal.com/api/v1/notifications"
        |>  HTTPoison.post!(body |> Poison.encode!, ["Content-Type": "application/json", "Authorization": "Basic #{@key}"])

        response.body |> Poison.decode!
    end
end