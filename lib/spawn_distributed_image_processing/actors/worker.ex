defmodule SpawnDistributedImageProcessing.Actors.Worker do
  use SpawnSdk.Actor,
    abstract: true,
    state_type: Spawn.Actors.Protocol.Worker.State

  alias SpawnDistributedImageProcessing.Nx.SpawnNx.{
    BinaryConverter,
    ShapeConverter,
    TypeConverter
  }

  alias Spawn.Actors.Protocol.Common.Image

  alias Spawn.Actors.Protocol.Worker.{ProcessRequest, ProcessResponse}

  defact process(
           %ProcessRequest{image: %Image{binary: binary, shape: shape, type: type} = _image_type} =
             _request,
           %Context{state: state} = _ctx
         ) do
    source_binary = BinaryConverter.from_proto(binary)
    source_shape = ShapeConverter.from_proto(shape)
    source_type = TypeConverter.from_proto(type)

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

    image_type = Image.new(binary: binary, shape: shape, type: type)
    response = ProcessResponse.new(image: image_type)

    %Value{}
    |> Value.of(response, state)
    |> Value.reply!()
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
