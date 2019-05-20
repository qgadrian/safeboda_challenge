defmodule SafeBoda.PromoCodeWeb.PageControllerTest do
  use SafeBoda.PromoCodeWeb.ConnCase
  use SafeBoda.PromoCodeStore.Suppport.RepoCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
