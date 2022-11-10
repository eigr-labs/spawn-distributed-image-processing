defmodule SpawnDistributedImageProcessing.Actors.Notification do
  use SpawnSdk.Actor,
    name: "notification",
    channel: "notifications",
    persistent: false

  require Logger

  alias Spawn.Actors.Domain.Worker.ProcessResponse

  defact notify(%ProcessResponse{} = request, _ctx) do
    Logger.info("File Processing Done. Result: #{inspect(request)}")

    Value.of()
    |> Value.noreply!(force: true)
  end
end
