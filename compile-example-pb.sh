#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

protoc --elixir_out=gen_descriptors=true:./lib/spawn_distributed_image_processing/nx/protocol --proto_path=priv/protos priv/protos/nx.proto

protoc --elixir_out=gen_descriptors=true:./lib/spawn_distributed_image_processing/actors/domain --proto_path=priv/protos priv/protos/common.proto
protoc --elixir_out=gen_descriptors=true:./lib/spawn_distributed_image_processing/actors/domain --proto_path=priv/protos priv/protos/orchestrator.proto
protoc --elixir_out=gen_descriptors=true:./lib/spawn_distributed_image_processing/actors/domain --proto_path=priv/protos priv/protos/worker.proto
