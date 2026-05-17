defmodule Beamline.Repo.Migrations.CreateProviders do
  use Ecto.Migration

  def change do
    create table(:providers) do
      add :name, :string, null: false
      add :slug, :string
      add :type, :string, null: false, default: "openai_compatible"
      add :base_url, :string
      add :enabled, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:providers, [:slug])
  end
end
