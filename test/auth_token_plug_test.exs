defmodule AuthTokenPlugTest do
  use ExUnit.Case
  use Plug.Test

  doctest AuthTokenPlug
  
  @password_salt "moo891plo"
  @user_id "54da3fde31f40c76004324c9"

  @opts AuthTokenPlug.init(salt: @password_salt)
  
  setup do
    AuthTokenPlug.InMemory.start_link
    :ok
  end

  test "return 401 if not token in request" do
    conn = conn(:get, "/hello")
    conn = AuthTokenPlug.call(conn, @opts)
    assert conn.status == 401 
  end

  test "return 401 if bad token in request" do
    token = "bad"
    conn = conn(:get, "/hello", token: token)
    conn = AuthTokenPlug.call(conn, @opts)
    assert conn.status == 401 
  end

  test "set :token_data from token" do
    token = "token!" 
    conn = conn(:get, "/hello", token: token)
    conn = AuthTokenPlug.call(conn, @opts)
    assert conn.assigns[:token_data] == @user_id
    assert AuthTokenPlug.get_data(conn) == @user_id
  end

end
