defmodule VExchange.Samples do
  @moduledoc """
  The Samples context.
  """
  require Logger
  import Ecto.Query, warn: false
  alias VExchange.Repo.Local, as: Repo

  alias VExchange.Sample
  alias VExchange.QueryCache

  @doc """
  Returns the list of samples.

  ## Examples

      iex> list_samples()
      [%Sample{}, ...]

  """
  def list_samples(opts \\ %{}) do
    from(s in Sample)
    |> filter_by_hash(opts)
    |> Repo.all()
  end

  def super_quick_list_samples() do
    query = from(s in Sample, limit: 10)

    Repo.all(query)
  end

  def quick_list_samples() do
    query = from(s in Sample, order_by: [desc: s.inserted_at], limit: 20)

    Repo.all(query)
  end

  defp filter_by_hash(query, %{hash: hash}) when byte_size(hash) not in [32, 40, 64, 128] do
    query
  end

  defp filter_by_hash(query, %{hash: hash}) when byte_size(hash) == 32 do
    where(query, [s], s.md5 == ^hash)
  end

  defp filter_by_hash(query, %{hash: hash}) when byte_size(hash) == 40 do
    where(query, [s], s.sha1 == ^hash)
  end

  defp filter_by_hash(query, %{hash: hash}) when byte_size(hash) == 64 do
    where(query, [s], s.sha256 == ^hash)
  end

  defp filter_by_hash(query, %{hash: hash}) when byte_size(hash) == 128 do
    where(query, [s], s.sha512 == ^hash)
  end

  defp filter_by_hash(query, _), do: query

  def get_sample_count!(), do: Repo.aggregate(Sample, :count)

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
    |> case do
      {:ok, _} = result ->
        if Application.get_env(:v_exchange, :env) != :test do
          QueryCache.update()
        end

        result

      result ->
        result
    end
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

  @doc """
  Gets a single sample by sha256.
  """
  def get_sample_by_sha256(sha256) do
    from(s in Sample, where: s.sha256 == ^sha256)
    |> Repo.one()
  end

  @doc """
  Returns params for inserting a `Sample` record from a binary file
  """
  def build_sample_params(file, user_id) when is_binary(file) do
    type = "unknown"

    %{
      md5: md5,
      sha1: sha1,
      sha256: sha256,
      sha512: sha512
    } = get_hashes(file)

    %{
      md5: md5,
      sha1: sha1,
      sha256: sha256,
      sha512: sha512,
      type: type,
      size: byte_size(file),
      names: [sha256],
      s3_object_key: sha256,
      first_seen: DateTime.utc_now() |> DateTime.truncate(:second),
      user_id: user_id
    }
  end

  # Used for direct to s3 uploads
  def build_sample_params(file, upload, user_id) when is_binary(file) do
    type = if upload.client_type == "", do: "unknown", else: upload.client_type

    %{
      md5: md5,
      sha1: sha1,
      sha256: sha256,
      sha512: sha512
    } = get_hashes(file)

    %{
      md5: md5,
      sha1: sha1,
      sha256: sha256,
      sha512: sha512,
      type: type,
      size: upload.client_size,
      names: [upload.client_name],
      s3_object_key: sha256,
      first_seen: DateTime.utc_now() |> DateTime.truncate(:second),
      user_id: user_id
    }
  end

  defp get_hashes(file) do
    md5 =
      :crypto.hash(:md5, file)
      |> Base.encode16()
      |> String.downcase()

    sha1 =
      :crypto.hash(:sha, file)
      |> Base.encode16()
      |> String.downcase()

    sha256 =
      :crypto.hash(:sha256, file)
      |> Base.encode16()
      |> String.downcase()

    sha512 =
      :crypto.hash(:sha3_512, file)
      |> Base.encode16()
      |> String.downcase()

    # Logger.error(
    #   "File: #{inspect(file)}, md5: #{inspect(md5)}, sha1: #{inspect(sha1)}, sha256: #{inspect(sha256)}, sha512: #{inspect(sha512)}"
    # )

    %{
      md5: md5,
      sha1: sha1,
      sha256: sha256,
      sha512: sha512
    }
  end

  @one_mb 1_048_576
  @size_limit_mbs 50

  @doc """
  Returns the size limit for sample uploads
  """
  def size_limit(), do: @one_mb * @size_limit_mbs

  @doc """
  Returns true if we the file is below our
  """
  def is_below_size_limit(binary), do: byte_size(binary) <= size_limit()
end
