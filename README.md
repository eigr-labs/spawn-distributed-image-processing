# Spawn Distributed Image Processing

Example of distributed image processing..

This example was inspired by that talk https://youtu.be/RkMzCQm-Ws4

## Run

```shell
MIX_ENV=dev PROXY_CLUSTER_STRATEGY=epmd PROXY_DATABASE_TYPE=mysql  PROXY_DATABASE_POOL_SIZE=10 SPAWN_STATESTORE_KEY=3Jnb0hZiHIzHTOih7t2cTEPEpY98Tu1wvQkPfq/XwqE= iex --name spawn_a@127.0.0.1 -S mix
```

> **_NOTE:_** This example uses the MySQL database as persistent storage for its actors. And it is also expected that you have previously created a database called eigr-functions-db in the MySQL instance. For more information see Spawn documentation [here](https://github.com/eigr/spawn)

```elixir
SpawnDistributedImageProcessing.push_work("priv/images/actor-mesh.png")
```

If you want to go up one more node just do:

```shell
MIX_ENV=dev PROXY_CLUSTER_STRATEGY=epmd PROXY_DATABASE_TYPE=mysql SPAWN_STATESTORE_KEY=3Jnb0hZiHIzHTOih7t2cTEPEpY98Tu1wvQkPfq/XwqE= iex --name spawn_a1@127.0.0.1 -S mix
```