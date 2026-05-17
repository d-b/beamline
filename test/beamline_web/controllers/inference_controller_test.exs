defmodule BeamlineWeb.InferenceControllerTest do
  use BeamlineWeb.ConnCase

  describe "POST /v1/chat/completions" do
    test "responds with 200", %{conn: conn} do
      conn = post(conn, ~p"/v1/chat/completions", %{})
      assert json_response(conn, 200)
    end
  end

  describe "POST /v1/completions" do
    test "responds with 200", %{conn: conn} do
      conn = post(conn, ~p"/v1/completions", %{})
      assert json_response(conn, 200)
    end
  end

  describe "POST /v1/responses" do
    test "responds with 200", %{conn: conn} do
      conn = post(conn, ~p"/v1/responses", %{})
      assert json_response(conn, 200)
    end
  end

  describe "POST /v1/embeddings" do
    test "responds with 200", %{conn: conn} do
      conn = post(conn, ~p"/v1/embeddings", %{})
      assert json_response(conn, 200)
    end
  end

  describe "GET /v1/models" do
    test "responds with 200", %{conn: conn} do
      conn = get(conn, ~p"/v1/models")
      assert json_response(conn, 200)
    end
  end
end
