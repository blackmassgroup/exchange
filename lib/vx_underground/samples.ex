defmodule VxUnderground.Samples do
  @moduledoc """
  The Samples context.
  """

  import Ecto.Query, warn: false
  alias VxUnderground.Repo.Local, as: Repo

  alias VxUnderground.Samples.Sample

  @doc """
  Returns the list of samples.

  ## Examples

      iex> list_samples()
      [%Sample{}, ...]

  """

  # def list_samples(params), do: base_query() |> filter(params) |> limit(50) |> Repo.all()

  # def list_samples(), do: base_query() |> limit(50) |> Repo.all()

  def list_samples(opts \\ []) do
    base_query()
    |> filter(opts)
    |> sort(opts)
    |> limit(10)
    |> Repo.all()
  end

  defp base_query(), do: from(s in Sample)

  defp sort(query, %{sort_by: sort_by, sort_dir: sort_dir})
       when sort_by in [:Size, :Type, :"First seen"] and
              sort_dir in [:asc, :desc] do
    sort_by =
      case sort_by do
        :Size -> :size
        :Type -> :type
        :"First seen" -> :first_seen
      end

    order_by(query, {^sort_dir, ^sort_by})
  end

  defp sort(query, _opts), do: query

  defp filter(query, opts) do
    query
    |> filter_by_hash(opts)
  end

  defp filter_by_hash(query, %{hash: hash})
       when is_binary(hash) and hash != "" and byte_size(hash) == 32 do
    where(query, [s], s.md5 == ^hash)
  end

  defp filter_by_hash(query, %{hash: hash})
       when is_binary(hash) and hash != "" and byte_size(hash) == 40 do
    where(query, [s], s.sha1 == ^hash)
  end

  defp filter_by_hash(query, %{hash: hash})
       when is_binary(hash) and hash != "" and byte_size(hash) == 64 do
    where(query, [s], s.sha256 == ^hash)
  end

  defp filter_by_hash(query, %{hash: hash})
       when is_binary(hash) and hash != "" and byte_size(hash) == 128 do
    where(query, [s], s.sha512 == ^hash)
  end

  defp filter_by_hash(query, %{hash: hash})
       when is_binary(hash) and hash != "" do
    where(
      query,
      [s],
      s.md5 == ^hash or s.sha1 == ^hash or
        s.sha256 == ^hash or s.sha512 == ^hash
    )
  end

  defp filter_by_hash(query, _), do: query

  def infinity_scroll_query_aggregate(nil) do
    from(s in Sample)
    |> Repo.aggregate(:count)
  end

  def infinity_scroll_query_aggregate(search) do
    from(s in Sample)
    |> filter(%{hash: search})
    |> Repo.aggregate(:count)
  end

  @doc """
  Gets a single sample.

  Raises `Ecto.NoResultsError` if the Sample does not exist.

  ## Examples

      iex> get_sample!(123)
      %Sample{}

      iex> get_sample!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sample!(id), do: Repo.get!(Sample, id)

  @doc """
  Gets a single sample.


  ## Examples

      iex> get_sample!(123)
      %Sample{}

      iex> get_sample!(456)
      nil

  """
  def get_sample(id), do: Repo.get(Sample, id)

  @doc """
  Creates a sample.

  ## Examples

      iex> create_sample(%{field: value})
      {:ok, %Sample{}}

      iex> create_sample(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sample(attrs \\ %{}) do
    %Sample{}
    |> Sample.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sample.

  ## Examples

      iex> update_sample(sample, %{field: new_value})
      {:ok, %Sample{}}

      iex> update_sample(sample, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sample(%Sample{} = sample, attrs) do
    sample
    |> Sample.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sample.

  ## Examples

      iex> delete_sample(sample)
      {:ok, %Sample{}}

      iex> delete_sample(sample)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sample(%Sample{} = sample) do
    Repo.delete(sample)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sample changes.

  ## Examples

      iex> change_sample(sample)
      %Ecto.Changeset{data: %Sample{}}

  """
  def change_sample(%Sample{} = sample, attrs \\ %{}) do
    Sample.changeset(sample, attrs)
  end
end
