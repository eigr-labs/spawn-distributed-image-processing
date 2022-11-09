defmodule SpawnDistributedImageProcessing.Actors.Orchestrator do
  use SpawnSdk.Actor,
    name: "orchestrator",
    state_type: Spawn.Actors.Protocol.Orchestrator.State

  require Logger

  alias Spawn.Actors.Protocol.Orchestrator.State
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
           %ImageProcessingRequest{image_source_bytes: image} = request,
           %Context{state: _state} = _ctx
         ) do
    Logger.debug("Orchestrator Received ImageProcessingRequest: [#{inspect(request)}]")
    dir = System.tmp_dir!()
    filename = "image-#{Uniq.UUID.uuid4()}"
    tmp_file = Path.join(dir, filename)
    File.write!(tmp_file, image)

    img =
      Evision.imread!(tmp_file)
      |> Evision.Nx.to_nx!()

    source_binary =
      Nx.to_binary(img)
      |> BinaryConverter.to_proto()

    source_shape =
      Nx.shape(img)
      |> ShapeConverter.to_proto()

    source_type =
      Nx.type(img)
      |> TypeConverter.to_proto()

    image_type = Image.new(binary: source_binary, shape: source_shape, type: source_type)
    request = ProcessRequest.new!(image: image_type)

    # This will start image processing on possibly any other Node
    process_response =
      {:ok,
       %ProcessResponse{
         image: %Spawn.Actors.Protocol.Common.Image{
           type: %Spawn.Nx.Protocol.Type{} = type,
           shape: %Spawn.Nx.Protocol.Shape{} = shape,
           binary: %Spawn.Nx.Protocol.Binary{} = binary
         }
       }} =
      SpawnSdk.invoke("worker-#{filename}",
        ref: Worker,
        system: @system,
        command: "process",
        payload: request
      )

    Logger.debug("Process Response: #{inspect(process_response)}")
    sink_binary = BinaryConverter.from_proto(binary)
    sink_shape = ShapeConverter.from_proto(shape)
    sink_type = TypeConverter.from_proto(type)

    img =
      Nx.from_binary(sink_binary, sink_type)
      |> Nx.reshape(sink_shape)
      |> Evision.Nx.to_mat!()

    Evision.imwrite!("priv/images/result.png", img)

    %Value{}
    |> Value.of(%ImageProcessingResponse{}, %State{})
    |> Value.reply!()
  end
end
