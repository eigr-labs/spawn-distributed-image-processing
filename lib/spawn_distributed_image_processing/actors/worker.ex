defmodule SpawnDistributedImageProcessing.Actors.Worker do
  use SpawnSdk.Actor,
    abstract: true,
    persistent: false

  require Logger

  alias SpawnDistributedImageProcessing.Nx.SpawnNx.{
    BinaryConverter,
    ShapeConverter,
    TypeConverter
  }

  alias Spawn.Actors.Domain.Common.Image

  alias Spawn.Actors.Domain.Worker.{ProcessRequest, ProcessResponse}

  defact process(
           %ProcessRequest{
             image: %Image{binary: b, shape: s, type: t} = image
           } = request,
           %Context{} = _ctx
         ) do
    Logger.debug("Worker Received ProcessRequest: [#{inspect(request)}]")
    source_binary = BinaryConverter.from_proto(b)
    source_shape = ShapeConverter.from_proto(s)
    source_type = TypeConverter.from_proto(t)

    dst_img = process_image(source_type, source_shape, source_binary)

    binary =
      Nx.to_binary(dst_img)
      |> BinaryConverter.to_proto()

    shape =
      Nx.shape(dst_img)
      |> ShapeConverter.to_proto()

    type =
      Nx.type(dst_img)
      |> TypeConverter.to_proto()

    image_type = %Image{image | binary: binary, shape: shape, type: type}
    response = ProcessResponse.new(image: image_type)

    Value.of()
    |> Value.effect(SideEffect.to("orchestrator", :complete, response))
    |> Value.noreply!(force: true)
  end

  def process_image(type, shape, binary) do
    # reconstruction of an image
    dst_img =
      Nx.from_binary(binary, type)
      |> Nx.reshape(shape)
      |> Evision.Nx.to_mat!()
      # image processing
      |> Evision.threshold!(127, 255, Evision.cv_THRESH_BINARY())
      |> elem(1)
      |> Evision.Nx.to_nx!()

    dst_img
  end
end
