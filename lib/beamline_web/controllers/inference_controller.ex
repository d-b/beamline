defmodule BeamlineWeb.InferenceController do
  use BeamlineWeb, :controller

  def chat_completions(conn, _params) do
    json(conn, %{"endpoint" => "chat_completions"})
  end

  def completions(conn, _params) do
    json(conn, %{"endpoint" => "completions"})
  end

  def embeddings(conn, _params) do
    json(conn, %{"endpoint" => "embeddings"})
  end

  def responses(conn, _params) do
    json(conn, %{"endpoint" => "responses"})
  end

  def models(conn, _params) do
    json(conn, %{"endpoint" => "models"})
  end
end
