use Mix.Config

import_config "../apps/*/config/config.exs"

config :git_hooks,
  verbose: true,
  hooks: [
    pre_commit: [
      tasks: [
        "mix format"
      ]
    ],
    pre_push: [
      verbose: false,
      tasks: [
        "mix dialyzer",
        "mix test"
      ]
    ]
  ]
