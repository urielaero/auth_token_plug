defmodule AuthTokenPlug.InMemory do

  @user_id "54da3fde31f40c76004324c9"

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def verify(_endpoint, _salt, "token!", _opts) do
    {:ok, @user_id}
  end

  def verify(_endpoint, _salt, token, _opts) do
    Agent.get(__MODULE__, fn pass -> 
      user_pass = Dict.get(pass, token)
      if user_pass, do: {:ok, user_pass}, else: {:error, :bad_token}
    end)

  end

  def sign(_endpoint, _salt, user_id) do
    hash = md5 user_id
    Agent.update(__MODULE__, fn users -> 
      Dict.put(users, hash, user_id)
    end)
    hash
  end

  defp md5(id) do
    id_string = to_string id
    :crypto.hash(:md5, id_string)
    |> :erlang.bitstring_to_list
    |> Enum.map(&(:io_lib.format("~2.16.0b", [&1]))) 
    |> List.flatten 
    |> :erlang.list_to_bitstring
  end
end
