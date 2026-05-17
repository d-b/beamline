defmodule Beamline.Repo.Migrations.CreateModels do
  use Ecto.Migration

  def change do
    create table(:models) do
      add :name, :string, null: false
      add :slug, :string
      add :description, :string

      add :public_name, :string
      add :upstream_name, :string

      add :enabled, :boolean, default: true, null: false
      add :priority, :integer, default: 0, null: false

      add :context_window, :integer
      add :max_output_tokens, :integer

      add :provider_id, references(:providers, on_delete: :delete_all)

      timestamps()
    end

    create index(:models, [:provider_id])
    create unique_index(:models, [:provider_id, :slug])
    create index(:models, [:public_name])
  end
end
