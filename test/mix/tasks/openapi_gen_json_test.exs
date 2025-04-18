defmodule Mix.Tasks.Openapi.Gen.JsonTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  @output_path "tmp/openapi_test.json"

  setup do
    on_exit(fn ->
      File.rm(@output_path)
    end)
  end

  test "generates OpenAPI JSON file" do
    output = capture_io(fn ->
      Mix.Tasks.Openapi.Gen.Json.run(["-o", @output_path])
    end)

    assert output =~ "Generated OpenAPI specification at #{@output_path}"
    assert File.exists?(@output_path)

    json = File.read!(@output_path)
    spec = Jason.decode!(json)

    assert spec["info"]["title"] == "JetLag Hide & Seek Game API"
    assert spec["info"]["version"] == "1.0.0"
    assert spec["paths"]["/api/games/check/{code}"] != nil
    assert spec["components"]["schemas"]["CheckGameExistsResponse"] != nil
  end
end
