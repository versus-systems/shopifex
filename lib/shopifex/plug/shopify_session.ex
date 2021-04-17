defmodule Shopifex.Plug.ShopifySession do
  import Plug.Conn
  import Phoenix.Controller
  require Logger

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _) do
    token = Guardian.Plug.current_token(conn)
    Logger.info("Token: #{token}")

    case Web.Shopify.Plug.Guardian.resource_from_token(token) do
      {:ok, shop, _claims} ->
        put_shop_in_session(conn, shop)

      error ->
        error
    end
  end

  def put_shop_in_session(conn, shop) do
    Logger.info("We are putting shop info in!")
    # Create a new token right away for the next request
    {:ok, token, claims} = Shopifex.Guardian.encode_and_sign(shop)

    conn
    |> Guardian.Plug.put_current_resource(shop)
    |> Guardian.Plug.put_current_claims(claims)
    |> Guardian.Plug.put_current_token(token)
    |> Plug.Conn.put_private(:shop_url, shop.url)
    |> Plug.Conn.put_private(:shop, shop)
  end
end
