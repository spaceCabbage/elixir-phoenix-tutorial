defmodule ChatroomWeb.PageController do
  use ChatroomWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
