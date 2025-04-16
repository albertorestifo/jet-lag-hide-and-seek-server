defmodule JetLagServer.Repo do
  use Ecto.Repo,
    otp_app: :jet_lag_server,
    adapter: Ecto.Adapters.SQLite3
end
