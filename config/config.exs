use Mix.Config

# Redefine logger format.
#
config :logger, :console,
  format: "$date $time [$level] $levelpad$message\n"

# Exq configuration
# See https://github.com/akira/exq for more information.
#
config :exq,
  host: "localhost",
  port: 6379,
  database: 1,
  password: nil,
  namespace: "bpe",
  queues: [
    {"default",                      1},
    {"job_poller",                   1},
    {"job_configurator",             1},
    {"job_to_recipients_converter",  1},
    {"recipient_creator",           10},
    {"email_personalizer",          10},
    {"email_sender",                10},
    {"recipient_status_updater",    20}
  ],
  middleware: [
    #Exq.Middleware.Stats, # Disabled in case of potential memory leak
    Exq.Middleware.Job,
    Exq.Middleware.Manager,
    Exq.Middleware.Logger
  ],
  scheduler_enable: true,
  scheduler_poll_timeout: 200,
  poll_timeout: 100,
  redis_timeout: 5000,
  genserver_timeout: 5000,
  reconnect_on_sleep: 100,
  max_retries: 25

# ExqUi configuration
# See https://github.com/akira/exq_ui for more information.
#
#config :exq_ui,
#  webport: 4040,
#  web_namespace: ""

# BPE configuration
#
config :bpe,
  name: BPE,
  node: "bpe@127.0.0.1",

  # MongoDB configuration
  # See https://github.com/ericmj/mongodb for more information.
  #
  # - hostname:  Server hostname (default: localhost)
  # - port:      Server port (default: 27017)
  # - database:  Database name (required)
  # - username:  Database username
  # - password:  Database user password
  # - backoff:   Backoff time for reconnects, the first reconnect is
  #              instantaneous (default: 1000)
  # - timeout:   TCP connect and receive timeouts (default: 5000)
  # - w:         The number of servers to replicate to before returning from write
  #              operators, a 0 value will return immediately, :majority will wait
  #              until the operation propagates to a majority of members in the
  #              replica set (default: 1)
  # - j:         If true, the write operation will only return after it has been
  #              committed to journal (default: false)
  # - wtimeout:  If the write concern is not satisfied in the specified interval,
  #              the operation returns an error
  # - pool_size: Number of connections to mongodb (default the number of workers
  #              from recipient_creator and recipient_status_updater queues)
  #
  mongodb: [
    database: "bpe"
  ],

  # Template engine service
  #
  # - url: Full qualified url of the template engine service
  #        This url will be expanded by /:recipient.name/:recipient.email
  #
  template_engine: [
    url: "http://localhost:5050/"
  ]

# Custom configuration
#
if File.exists?("./config/my_config.exs"), do: import_config "my_config.exs"
