defmodule Beamline.Providers.ProviderType do
  @values [
    :openai_compatible,
    :openai,
    :azure_openai,
    :anthropic,
    :google_gemini,
    :google_vertex,
    :aws_bedrock,
    :mistral,
    :cohere,
    :custom
  ]

  def values, do: @values
end
