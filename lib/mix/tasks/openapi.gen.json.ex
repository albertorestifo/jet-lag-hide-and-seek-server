defmodule Mix.Tasks.Openapi.Gen.Json do
  @moduledoc """
  Generates a static OpenAPI JSON file from the API spec.

  ## Usage

      mix openapi.gen.json -o priv/static/openapi.json
  """

  use Mix.Task
  alias JetLagServerWeb.ApiSpec

  @shortdoc "Generates a static OpenAPI JSON file"
  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    {opts, _} =
      OptionParser.parse!(args,
        strict: [output: :string],
        aliases: [o: :output]
      )

    output_file = opts[:output] || "priv/static/openapi.json"
    spec = ApiSpec.spec() |> Jason.encode!(pretty: true)

    output_file
    |> Path.dirname()
    |> File.mkdir_p!()

    File.write!(output_file, spec)

    Mix.shell().info("Generated OpenAPI specification at #{output_file}")
  end
end
