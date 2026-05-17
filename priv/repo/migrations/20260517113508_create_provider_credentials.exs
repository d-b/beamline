defmodule Beamline.Repo.Migrations.CreateProviderCredentials do
  use Ecto.Migration

  def change do
    create table(:provider_credentials) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :enabled, :boolean, default: true, null: false

      add :api_key_source, :string, default: "none", null: false
      add :api_key_encrypted, :binary
      add :api_key_env_var, :string
      add :api_key_file_path, :string
      add :api_key_external_ref, :string

      add :model_scope, :string, default: "all", null: false
      add :priority, :integer, default: 100, null: false
      add :weight, :decimal, precision: 10, scale: 4, default: "1.0", null: false

      add :provider_id, references(:providers, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:provider_credentials, [:provider_id])
    create unique_index(:provider_credentials, [:provider_id, :slug])
  end
end
