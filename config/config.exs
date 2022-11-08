import Config

config :logger,
  backends: [:console],
  truncate: 65536

# Our Console Backend-specific configuration
config :logger, :console,
  format: "$date $time [$node]:[$metadata]:[$level]:$message\n",
  metadata: [:pid]

config :protobuf, extensions: :enabled

import_config "#{config_env()}.exs"
