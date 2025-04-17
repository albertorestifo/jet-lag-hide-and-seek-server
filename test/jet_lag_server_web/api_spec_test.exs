defmodule JetLagServerWeb.ApiSpecTest do
  use JetLagServerWeb.ConnCase, async: true
  alias OpenApiSpex.OpenApi

  test "OpenAPI spec is valid", %{} do
    spec = JetLagServerWeb.ApiSpec.spec()
    assert %OpenApi{} = spec
    assert map_size(spec.paths) > 0
    assert Map.keys(spec.components.schemas) |> length() > 0
  end

  test "OpenAPI spec can be retrieved", %{conn: conn} do
    conn = get(conn, "/api/openapi")
    assert json_response(conn, 200)["info"]["title"] == "JetLag Hide & Seek Game API"
    assert json_response(conn, 200)["info"]["version"] == "1.0.0"
  end

  test "SwaggerUI is accessible", %{conn: conn} do
    conn = get(conn, "/api/swaggerui")
    assert html_response(conn, 200) =~ "swagger-ui"
  end
end
