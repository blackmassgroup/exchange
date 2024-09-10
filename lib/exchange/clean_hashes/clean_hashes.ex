defmodule Exchange.CleanHashes do
  @moduledoc """
  The CleanHashes context.
  """

  import Ecto.Query, warn: false
  alias Exchange.Repo

  alias Exchange.CleanHashes.CleanHash

  @doc """
  Returns the list of clean_hashes.

  ## Examples

      iex> list_clean_hashes()
      [%CleanHash{}, ...]

  """
  def list_clean_hashes do
    Repo.all(CleanHash)
  end

  @doc """
  Gets a single clean_hash.

  Raises `Ecto.NoResultsError` if the Clean hash does not exist.

  ## Examples

      iex> get_clean_hash!(123)
      %CleanHash{}

      iex> get_clean_hash!(456)
      ** (Ecto.NoResultsError)

  """
  def get_clean_hash!(id), do: Repo.get!(CleanHash, id)

  @doc """
  Creates a clean_hash.

  ## Examples

      iex> create_clean_hash(%{field: value})
      {:ok, %CleanHash{}}

      iex> create_clean_hash(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_clean_hash(attrs \\ %{}) do
    %CleanHash{}
    |> CleanHash.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a clean_hash.

  ## Examples

      iex> update_clean_hash(clean_hash, %{field: new_value})
      {:ok, %CleanHash{}}

      iex> update_clean_hash(clean_hash, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_clean_hash(%CleanHash{} = clean_hash, attrs) do
    clean_hash
    |> CleanHash.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a clean_hash.

  ## Examples

      iex> delete_clean_hash(clean_hash)
      {:ok, %CleanHash{}}

      iex> delete_clean_hash(clean_hash)
      {:error, %Ecto.Changeset{}}

  """
  def delete_clean_hash(%CleanHash{} = clean_hash) do
    Repo.delete(clean_hash)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking clean_hash changes.

  ## Examples

      iex> change_clean_hash(clean_hash)
      %Ecto.Changeset{data: %CleanHash{}}

  """
  def change_clean_hash(%CleanHash{} = clean_hash, attrs \\ %{}) do
    CleanHash.changeset(clean_hash, attrs)
  end
end
