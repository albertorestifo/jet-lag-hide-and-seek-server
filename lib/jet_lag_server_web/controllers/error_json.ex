defmodule JetLagServerWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render("400.json", %{changeset: changeset}) do
    # When we receive a changeset with errors
    %{
      code: "validation_error",
      message: "Validation failed",
      details: traverse_errors(changeset)
    }
  end

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def error(%{error: error}) do
    # For other types of errors
    %{
      code: "server_error",
      message: "An error occurred",
      details: inspect(error)
    }
  end

  def error(%{status: status, message: message}) do
    # For custom error responses
    %{
      code: status_to_code(status),
      message: message
    }
  end

  defp status_to_code(401), do: "unauthorized"
  defp status_to_code(403), do: "forbidden"
  defp status_to_code(404), do: "not_found"
  defp status_to_code(_), do: "error"

  defp traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
