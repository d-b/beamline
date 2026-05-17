defmodule Beamline.Providers.Provider do
  @moduledoc """
  The Provider schema represents an LLM provider configuration in the system.
  It includes details about the provider's type, API endpoint, and how to retrieve the API key.
  """

  use Beamline.Schema

  alias Beamline.Providers.ProviderType
  alias Beamline.Secrets.SecretType

  schema "providers" do
    field :name, :string
    field :slug, :string
    field :type, Ecto.Enum, values: ProviderType.values(), default: :openai_compatible

    field :base_url, :string
    field :enabled, :boolean, default: true

    field :api_key_source, Ecto.Enum, values: SecretType.values(), default: :env
    field :api_key_encrypted, :string
    field :api_key_env_var, :string
    field :api_key_file_path, :string
    field :api_key_external_ref, :string

    timestamps()
  end
end

