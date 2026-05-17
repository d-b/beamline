defmodule Beamline.Repo.Migrations.CreateProviderCredentialModels do
  use Ecto.Migration

  def change do
    create table(:provider_credential_models, primary_key: false) do
      add :provider_credential_id,
          references(:provider_credentials, on_delete: :delete_all),
          primary_key: true

      add :model_id,
          references(:models, on_delete: :delete_all),
          primary_key: true

      timestamps()
    end

    create index(:provider_credential_models, [:model_id])
  end
end
