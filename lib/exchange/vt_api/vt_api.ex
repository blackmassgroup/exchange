defmodule Exchange.VtApi do
  @moduledoc """
  The VtApi context.
  """

  import Ecto.Query, warn: false
  alias Exchange.Repo

  alias Exchange.VtApi.VtApiRequest

  @doc """
  Returns the list of vt_api_requests.

  ## Examples

      iex> list_vt_api_requests()
      [%VtApiRequest{}, ...]

  """
  def list_vt_api_requests do
    Repo.all(VtApiRequest)
  end

  @doc """
  Gets a single vt_api_request.

  Raises `Ecto.NoResultsError` if the Vt api request does not exist.

  ## Examples

      iex> get_vt_api_request!(123)
      %VtApiRequest{}

      iex> get_vt_api_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vt_api_request!(id), do: Repo.get!(VtApiRequest, id)

  @doc """
  Creates a vt_api_request.

  ## Examples

      iex> create_vt_api_request(%{field: value})
      {:ok, %VtApiRequest{}}

      iex> create_vt_api_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vt_api_request(attrs \\ %{}) do
    %VtApiRequest{}
    |> VtApiRequest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vt_api_request.

  ## Examples

      iex> update_vt_api_request(vt_api_request, %{field: new_value})
      {:ok, %VtApiRequest{}}

      iex> update_vt_api_request(vt_api_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vt_api_request(%VtApiRequest{} = vt_api_request, attrs) do
    vt_api_request
    |> VtApiRequest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vt_api_request.

  ## Examples

      iex> delete_vt_api_request(vt_api_request)
      {:ok, %VtApiRequest{}}

      iex> delete_vt_api_request(vt_api_request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vt_api_request(%VtApiRequest{} = vt_api_request) do
    Repo.delete(vt_api_request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vt_api_request changes.

  ## Examples

      iex> change_vt_api_request(vt_api_request)
      %Ecto.Changeset{data: %VtApiRequest{}}

  """
  def change_vt_api_request(%VtApiRequest{} = vt_api_request, attrs \\ %{}) do
    VtApiRequest.changeset(vt_api_request, attrs)
  end
end
