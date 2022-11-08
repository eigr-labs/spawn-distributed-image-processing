defmodule SpawnDistributedImageProcessing.Application do
  @moduledoc false
  use Application

  @system "sdip-system"

  @impl true
  def start(_type, _args) do
    children = [
      {
        SpawnSdk.System.Supervisor,
        system: @system,
        actors: [
          SpawnDistributedImageProcessing.Actors.Orchestrator,
          SpawnDistributedImageProcessing.Actors.Worker
        ]
      }
    ]

    opts = [strategy: :one_for_one, name: SpawnDistributedImageProcessing.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
