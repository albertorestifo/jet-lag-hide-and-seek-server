defmodule JetLagServerWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  """
  use JetLagServerWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: JetLagServerWeb.ErrorJSON)
    |> render("400.json", %{changeset: changeset})
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: JetLagServerWeb.ErrorJSON)
    |> render(:"404")
  end

  # This clause handles other errors.
  def call(conn, {:error, error}) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(json: JetLagServerWeb.ErrorJSON)
    |> render(:error, error: error)
  end
end
