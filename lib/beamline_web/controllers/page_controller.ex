defmodule BeamlineWeb.PageController do
  use BeamlineWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
