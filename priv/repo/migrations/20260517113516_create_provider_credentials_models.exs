defmodule Beamline.Repo.Migrations.CreateProviderCredentialsModels do
  use Ecto.Migration

  def change do
    create table(:provider_credentials_models, primary_key: false) do
      add :provider_credential_id,
          references(:provider_credentials, on_delete: :delete_all),
          primary_key: true

      add :model_id,
          references(:models, on_delete: :delete_all),
          primary_key: true

      timestamps()
    end

    create index(:provider_credentials_models, [:model_id])
  end
end
