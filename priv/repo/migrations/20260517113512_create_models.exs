defmodule Beamline.Repo.Migrations.CreateModels do
  use Ecto.Migration

  def change do
    create table(:models) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text

      add :public_name, :string, null: false
      add :upstream_name, :string, null: false

      add :enabled, :boolean, default: true, null: false
      add :priority, :integer, default: 100, null: false

      add :context_window, :integer
      add :max_output_tokens, :integer

      add :provider_id, references(:providers, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:models, [:provider_id, :slug])
    create unique_index(:models, [:provider_id, :public_name])
    create index(:models, [:provider_id])
    create index(:models, [:public_name])
  end
end
