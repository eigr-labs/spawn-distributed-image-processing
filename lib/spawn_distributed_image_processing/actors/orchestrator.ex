defmodule SpawnDistributedImageProcessing.Actors.Orchestrator do
  use SpawnSdk.Actor,
    name: "orchestrator",
    state_type: Spawn.Actors.Protocol.Orchestrator.State

  alias SpawnDistributedImageProcessing.Actors.Worker

  alias SpawnDistributedImageProcessing.Nx.SpawnNx.{
    BinaryConverter,
    ShapeConverter,
    TypeConverter
  }

  alias Spawn.Actors.Protocol.Common.Image

  alias Spawn.Actors.Protocol.Orchestrator.{
    ImageProcessingRequest,
    ImageProcessingResponse
  }

  alias Spawn.Actors.Protocol.Worker.{ProcessRequest, ProcessResponse}

  @system "sdip-system"

  defact push_task(
           %ImageProcessingRequest{image_source_bytes: image} = _request,
           %Context{state: state} = _ctx
         ) do
    dir = System.tmp_dir!()
    filename = "image-#{Uniq.UUID.uuid4()}"
    tmp_file = Path.join(dir, filename)
    File.write!(tmp_file, image)

    img =
      Evision.imread!(tmp_file)
      |> Evision.Nx.to_nx!()

    binary =
      Nx.to_binary(img)
      |> BinaryConverter.to_proto()

    shape =
      Nx.shape(img)
      |> ShapeConverter.to_proto()

    type =
      Nx.type(img)
      |> TypeConverter.to_proto()

    image_type = Image.new(binary: binary, shape: shape, type: type)
    request = ProcessRequest.new!(image: image_type)

    process_response =
      {:ok, %ProcessResponse{image: image_type}} =
      SpawnSdk.invoke("worker-#{filename}",
        ref: Worker,
        system: @system,
        command: "process",
        payload: request
      )

    %Value{}
    |> Value.of(%ImageProcessingResponse{}, state)
    |> Value.reply!()
  end
end
