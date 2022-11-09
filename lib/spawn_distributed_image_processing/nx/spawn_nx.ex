defmodule SpawnDistributedImageProcessing.Nx.SpawnNx do
  @moduledoc """
  `SpawnNx` Convert Nx types to and from Protobufs
  """

  defmodule ShapeConverter do
    alias Spawn.Nx.Protocol.Shape, as: ProtoShape

    @spec to_proto(tuple()) :: ProtoShape.t()
    def to_proto(shape), do: ProtoShape.new!(tuple: Tuple.to_list(shape))

    @spec from_proto(ProtoShape.t()) :: tuple
    def from_proto(%ProtoShape{tuple: tuple} = _shape), do: List.to_tuple(tuple)
  end

  defmodule TypeConverter do
    alias Spawn.Nx.Protocol.Type, as: ProtoType

    @spec to_proto(tuple()) :: ProtoType.t()
    def to_proto({name, size} = _type), do: ProtoType.new!(name: Atom.to_string(name), size: size)

    @spec from_proto(ProtoType.t()) :: tuple
    def from_proto(%ProtoType{name: name, size: size} = _shape),
      do: {String.to_existing_atom(name), size}
  end

  defmodule BinaryConverter do
    alias Spawn.Nx.Protocol.Binary, as: ProtoBinary

    @spec to_proto(binary) :: ProtoBinary.t()
    def to_proto(binary) when is_binary(binary) do
      ProtoBinary.new!(data: binary)
    end

    @spec from_proto(Spawn.Nx.Protocol.Binary.t()) :: binary
    def from_proto(%ProtoBinary{data: data} = _binary),
      do: data
  end
end
