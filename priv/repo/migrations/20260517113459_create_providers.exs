defmodule Beamline.Repo.Migrations.CreateProviders do
  use Ecto.Migration

  def change do
    create table(:providers) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :type, :string, null: false, default: "openai_compatible"

      add :base_url, :string, null: false
      add :enabled, :boolean, default: true, null: false

      add :config, :map, default: %{}, null: false

      timestamps()
    end

    create unique_index(:providers, [:slug])
    create index(:providers, [:type])
    create index(:providers, [:enabled])
  end
end
