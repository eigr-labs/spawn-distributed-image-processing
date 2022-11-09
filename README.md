# Spawn Distributed Image Processing

Exemplo de processamento de imagem distribuída.

This example was inspired by that talk https://youtu.be/RkMzCQm-Ws4

## Run

```shell
MIX_ENV=dev PROXY_CLUSTER_STRATEGY=epmd PROXY_DATABASE_TYPE=mysql  PROXY_DATABASE_POOL_SIZE=10 SPAWN_STATESTORE_KEY=3Jnb0hZiHIzHTOih7t2cTEPEpY98Tu1wvQkPfq/XwqE= iex --name spawn_a@127.0.0.1 -S mix
```

```elixir
SpawnDistributedImageProcessing.push_work("priv/images/actor-mesh.png")
```