defmodule VxUndergroundWeb.UserApiSessionJSON do
  alias VxUnderground.Accounts.User

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      token: user.api_key
    }
  end
end
