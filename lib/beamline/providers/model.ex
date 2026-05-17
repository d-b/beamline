defmodule Beamline.Providers.Model do
  @moduledoc """
  The Model schema represents a specific model offered by a provider, such as "qwen/qwen3.6-27b".
  It includes details about the model's capabilities, pricing, and configuration.
  """

  use Beamline.Schema

  alias Beamline.Providers.Provider

  schema "models" do
    field :name, :string
    field :slug, :string
    field :description, :string

    field :public_name, :string
    field :upstream_name, :string

    field :enabled, :boolean, default: true
    field :priority, :integer, default: 0

    field :context_window, :integer
    field :max_output_tokens, :integer

    belongs_to :provider, Provider

    timestamps()
  end
end
