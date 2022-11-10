defmodule SpawnDistributedImageProcessing.Actors.Orchestrator do
  use SpawnSdk.Actor,
    name: "orchestrator",
    persistent: false

  require Logger

  alias SpawnDistributedImageProcessing.Actors.Worker

  alias SpawnDistributedImageProcessing.Nx.SpawnNx.{
    BinaryConverter,
    ShapeConverter,
    TypeConverter
  }

  alias Spawn.Actors.Domain.Common.Image

  alias Spawn.Actors.Domain.Orchestrator.{
    ImageProcessingRequest,
    ImageProcessingResponse
  }

  alias Spawn.Actors.Domain.Worker.{ProcessRequest, ProcessResponse}

  @notification_channel "notifications"
  @system "sdip-system"
  @worker_pool 10

  defact push_task(
           %ImageProcessingRequest{
             path: path,
             filename: filename,
             image_source_bytes: image
           } = request,
           %Context{state: _state} = _ctx
         ) do
    Logger.info("Orchestrator Received ImageProcessingRequest: [#{inspect(request)}]")

    tmp_file = create_temp_file(filename, image)

    image_type = build_image(path, filename, tmp_file)
    request = ProcessRequest.new!(image: image_type)

    # This will spawning worker actor for image processing on possibly any other Node
    # We use a limited number of workers so we don't run out of environment resources
    worker_actor_name = "worker-#{:rand.uniform(@worker_pool)}"
    SpawnSdk.spawn_actor(worker_actor_name, system: @system, actor: Worker)

    %Value{}
    |> Value.value(%ImageProcessingResponse{})
    |> Value.effect(SideEffect.to(worker_actor_name, :process, request))
    |> Value.noreply!(force: true)
  end

  defact complete(
           %ProcessResponse{
             image: %Spawn.Actors.Domain.Common.Image{
               path: path,
               filename: filename,
               type: %Spawn.Nx.Protocol.Type{} = type,
               shape: %Spawn.Nx.Protocol.Shape{} = shape,
               binary: %Spawn.Nx.Protocol.Binary{} = binary
             }
           } = response,
           %Context{state: _state} = _ctx
         ) do
    Logger.info("Worker Process Response: #{inspect(response)}")
    sink_binary = BinaryConverter.from_proto(binary)
    sink_shape = ShapeConverter.from_proto(shape)
    sink_type = TypeConverter.from_proto(type)

    img =
      Nx.from_binary(sink_binary, sink_type)
      |> Nx.reshape(sink_shape)
      |> Evision.Nx.to_mat!()

    result_filename = "#{path}/result-#{filename}"
    Evision.imwrite!(result_filename, img)

    response = %ProcessResponse{response | full_file_path: result_filename}

    Value.of()
    |> Value.broadcast(Broadcast.to(@notification_channel, "notify", response))
    |> Value.void()
  end

  defp create_temp_file(filename, image) do
    dir = System.tmp_dir!()
    filename = "#{filename}-#{Uniq.UUID.uuid4()}"
    tmp_file = Path.join(dir, filename)
    File.write!(tmp_file, image)

    tmp_file
  end

  defp build_image(path, filename, file) do
    img =
      Evision.imread!(file)
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

    Image.new(
      path: path,
      filename: filename,
      binary: source_binary,
      shape: source_shape,
      type: source_type
    )
  end
end
