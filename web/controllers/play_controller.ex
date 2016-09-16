defmodule FamilyFeud.PlayController do
  use FamilyFeud.Web, :controller
  alias FamilyFeud.Game
  alias FamilyFeud.ActiveGame

  plug :load_game
  plug :require_game
  plug :authorize_access, "before admin" when action in [:admin]

  def admin(conn, _params) do
    active_game = Game.get_active_game(conn.assigns[:game])
    ActiveGame.get_active_round(active_game)

    render conn, :admin
  end

  def public(conn, _params) do
    render conn, :public, no_header: true
  end

  def load_game(conn, _) do
    game = case conn.params do
      %{"public_code" => code} ->
        Repo.get_by(Game, public_code: code)
      %{"game_id" => id} ->
        Repo.get_by(Game, id: id, user_id: current_user(conn).id)
    end

    assign(conn, :game, game)
  end

  def require_game(conn, _) do
    game = conn.assigns[:game]
    if game do
      conn
    else
      conn
      |> put_flash(:info, "Page not found")
      |> redirect(to: "/")
    end
  end

  def authorize_access(conn, _) do
    game = conn.assigns[:game]
    if game && game.user_id == current_user(conn).id do
      conn
    else
      conn
      |> put_flash(:info, "You don't have access to that.")
      |> redirect(to: "/")
    end
  end

end
