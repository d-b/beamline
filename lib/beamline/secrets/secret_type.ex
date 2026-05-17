defmodule Beamline.Secrets.SecretType do
  @values [
    :none,
    :env,
    :encrypted,
    :aws_secret_manager,
    :gcp_secret_manager,
    :azure_key_vault,
    :vault,
    :one_password
  ]

  def values, do: @values
end
