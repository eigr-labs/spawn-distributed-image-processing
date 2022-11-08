defmodule SpawnDistributedImageProcessing do
  @moduledoc """
  Documentation for `SpawnDistributedImageProcessing`.
  """

  alias SpawnSdk
  alias Spawn.Actors.Protocol.Orchestrator.{ImageProcessingRequest, ImageProcessingResponse}

  @system "sdip-system"
  @orchestrator_actor "orchestrator"

  def push_work(file) do
    {:ok, image_source_bytes} = File.read(file)
    task = ImageProcessingRequest.new(image_source_bytes: image_source_bytes)

    case SpawnSdk.invoke(
           @orchestrator_actor,
           system: @system,
           command: "push_task",
           payload: task
         ) do
      {:ok, %ImageProcessingResponse{image_sink_bytes: image}} ->
        {:ok, image}

      _ ->
        :error
    end
  end
end
