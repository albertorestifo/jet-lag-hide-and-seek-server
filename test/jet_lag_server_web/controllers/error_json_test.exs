defmodule JetLagServerWeb.ErrorJSONTest do
  use JetLagServerWeb.ConnCase

  test "renders 404" do
    assert JetLagServerWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert JetLagServerWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
