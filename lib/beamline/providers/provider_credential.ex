defmodule Beamline.Providers.ProviderCredential do
  @moduledoc """
  A credential set for a provider. A provider can have multiple credentials,
  each scoped to all models or a selected subset via the join table.
  """

  use Beamline.Schema

  alias Beamline.Providers.Provider
  alias Beamline.Providers.Model
  alias Beamline.Providers.ProviderCredentialModel

  schema "provider_credentials" do
    field :name, :string
    field :slug, :string
    field :enabled, :boolean, default: true

    field :api_key_source, Ecto.Enum,
      values: [:none, :env, :encrypted, :file, :external],
      default: :none

    field :api_key_encrypted, :binary
    field :api_key_env_var, :string
    field :api_key_file_path, :string
    field :api_key_external_ref, :string

    field :model_scope, Ecto.Enum,
      values: [:all, :selected],
      default: :all

    field :priority, :integer, default: 100
    field :weight, :decimal, default: Decimal.new("1.0")

    belongs_to :provider, Provider

    has_many :credential_models, ProviderCredentialModel

    many_to_many :models, Model,
      join_through: ProviderCredentialModel,
      join_keys: [
        provider_credential_id: :id,
        model_id: :id
      ]

    timestamps()
  end
end
