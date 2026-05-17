defmodule Beamline.Repo do
  use Ecto.Repo,
    otp_app: :beamline,
    adapter: Ecto.Adapters.Postgres
end
