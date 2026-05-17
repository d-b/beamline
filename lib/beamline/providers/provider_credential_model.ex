defmodule Beamline.Providers.ProviderCredentialModel do
  @moduledoc """
  Join table between ProviderCredential and Model.
  Used when model_scope is :selected to restrict a credential to specific models.
  """

  use Beamline.Schema

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "provider_credential_models" do
    belongs_to :provider_credential, Beamline.Providers.ProviderCredential
    belongs_to :model, Beamline.Providers.Model

    timestamps()
  end
end
