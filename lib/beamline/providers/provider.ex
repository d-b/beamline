defmodule Beamline.Providers.Provider do
  @moduledoc """
  The Provider schema represents an LLM provider configuration in the system.
  It includes details about the provider's type, API endpoint, and associated credentials.
  """

  use Beamline.Schema

  alias Beamline.Providers.ProviderType
  alias Beamline.Providers.ProviderCredential

  schema "providers" do
    field :name, :string
    field :slug, :string
    field :type, Ecto.Enum, values: ProviderType.values(), default: :openai_compatible

    field :base_url, :string
    field :enabled, :boolean, default: true

    has_many :credentials, ProviderCredential
    has_many :models, Beamline.Providers.Model

    timestamps()
  end
end
