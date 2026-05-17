defmodule Beamline.Secrets.SecretType do
  @moduledoc """
  Enum values for secret storage backends.
  """

  @values [
    :none,
    :env,
    :file,
    :encrypted,
    :aws_ssm_parameter,
    :aws_secrets_manager,
    :gcp_secret_manager,
    :azure_key_vault,
    :vault,
    :one_password
  ]

  def values, do: @values
end
