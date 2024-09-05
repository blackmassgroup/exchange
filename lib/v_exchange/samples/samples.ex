defmodule VExchange.Samples do
  @moduledoc """
  The Samples context.
  """
  require Logger
  import Ecto.Query, warn: false

  alias VExchange.CleanHashes
  alias Phoenix.PubSub
  alias VExchange.ObanJobs.Vt.SubmitVt
  alias VExchange.Repo.Local, as: Repo
  alias VExchange.Sample
  alias VExchange.CleanHashes
  alias VExchange.Services.VirusTotal
  alias VExchange.Services.S3

  @doc """
  Returns the list of samples.

  Possible options:
  - `:limit`: The maximum number of samples to return.
  - `:hash`: The hash of the sample to search for.

  ## Examples

      iex> list_samples()
      [%Sample{}, ...]

  """
  def list_samples(opts \\ %{})

  def list_samples(%{hash: hash} = opts) do
    limit = Map.get(opts, :limit, 20)

    from(s in Sample)
    |> filter_by_hash(%{hash: hash})
    |> limit(^limit)
    |> order_by([s], desc: s.inserted_at)
    |> select(
      [s],
      struct(s, [
        :id,
        :user_id,
        :first_seen,
        :names,
        :md5,
        :sha1,
        :sha256,
        :sha512,
        :s3_object_key,
        :size,
        :type,
        :tags,
        :inserted_at,
        :updated_at
      ])
    )
    |> Repo.all()
  end

  def list_samples(opts) do
    limit = Map.get(opts, :limit, 20)
    order = Map.get(opts, :order, :desc)

    from(s in Sample)
    |> order_by([s], {^order, s.inserted_at})
    |> limit(^limit)
    |> select(
      [s],
      struct(s, [
        :id,
        :user_id,
        :first_seen,
        :names,
        :md5,
        :sha1,
        :sha256,
        :sha512,
        :s3_object_key,
        :size,
        :type,
        :tags,
        :inserted_at,
        :updated_at
      ])
    )
    |> Repo.all()
  end

  defp filter_by_hash(query, %{hash: hash}) when byte_size(hash) not in [32, 40, 64, 128] do
    query
  end

  defp filter_by_hash(query, %{hash: hash}) when byte_size(hash) == 32 do
    from s in query, where: s.md5 == ^hash
  end

  defp filter_by_hash(query, %{hash: hash}) when byte_size(hash) == 40 do
    from s in query, where: s.sha1 == ^hash
  end

  defp filter_by_hash(query, %{hash: hash}) when byte_size(hash) == 64 do
    from s in query, where: s.sha256 == ^hash
  end

  defp filter_by_hash(query, %{hash: hash}) when byte_size(hash) == 128 do
    from s in query, where: s.sha512 == ^hash
  end

  defp filter_by_hash(query, _), do: query

  @doc """
  Gets the count of samples in the database.
  """
  def get_sample_count!() do
    Repo.one(from s in Sample, select: fragment("count(*) :: integer"))
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

      iex> get_sample(123)
      {:ok, %Sample{}}

      iex> get_sample(456)
      nil

  """
  def get_sample(id), do: Repo.get(Sample, id)

  @doc """
  Creates a sample.

  Queues the job to submits the sample to VirusTotal for processing
  and broadcasts a PubSub event for the ui to update.

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
      {:ok, sample} = result ->
        if Application.get_env(:v_exchange, :env) != :test do
          PubSub.broadcast(VExchange.PubSub, "samples", {:new_sample, sample})

          # %{
          #   "sha256" => sample.sha256,
          #   "is_new" => true,
          #   "is_first_request" => true
          # }
          # |> SubmitVt.new()
          # |> Oban.insert()
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
    |> case do
      {:ok, sample} = result ->
        if Application.get_env(:v_exchange, :env) != :test do
          PubSub.broadcast(VExchange.PubSub, "samples", {:updated_sample, sample})
        end

        result

      result ->
        result
    end
  end

  @doc """
  Deletes a sample.

  Also removes the sample from the cloud provider and
  broadcasts a PubSub event for the ui to update.

  ## Examples

      iex> delete_sample(sample)
      {:ok, %Sample{}}

      iex> delete_sample(sample)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sample(%Sample{} = sample) do
    with(
      {:ok, _} <- CleanHashes.create_clean_hash(%{sha256: sample.sha256}),
      {:ok, sample} = result <- Repo.delete(sample),
      {:ok, _} <- S3.delete_exchange_object(sample.sha256)
    ) do
      if Application.get_env(:v_exchange, :env) != :test do
        PubSub.broadcast(VExchange.PubSub, "samples", {:deleted_sample, sample})
      end

      result
    end
  end

  def delete_sample(nil), do: {:error, :nil_sent}

  def delete_sample(sha256) do
    get_sample_by_sha256(sha256)
    |> delete_sample()
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

  @doc """
  Processes the result of the status check

  If the sample is malware, we update the local sample data and post a comment
  """
  def process_vt_result(attrs) do
    comment = "File present on vx-underground.org | virus.exchange."
    sha256 = Map.get(attrs, "sha256")

    with true <- VirusTotal.is_malware?(attrs),
         {:ok, _} <- VirusTotal.post_file_comment(sha256, comment),
         {:ok, sample} <- update_sample_from_vt(attrs) do
      {:ok, sample}
    else
      false ->
        case delete_sample(sha256) do
          {:ok, %Sample{}} ->
            {:ok, :not_malware}

          {:error, %Ecto.Changeset{}} ->
            Logger.error(
              "Failed to delete sha256: #{sha256} from local database for not being malware"
            )

          {:error, _} ->
            Logger.error(
              "Failed to delete sha256: #{sha256} from cloud provider database for not being malware"
            )
        end

      {:error, %Ecto.Changeset{} = _cs} ->
        Logger.error("Error updating local sample #{sha256} from VT")
        {:error, :error_updating_local_sample}

      _ ->
        Logger.error("Error posting comment for #{sha256} to VT")
        {:error, :posting_comment}
    end
  end

  @doc """
  Updates a Sample from VT get sampe response

  Expects the response to be verified by `VirusTotal.is_malware?/1` already
  """
  def update_sample_from_vt(attrs) do
    sha256 = Map.get(attrs, "sha256")
    sample = get_sample_by_sha256(sha256)

    names =
      [Map.get(attrs, "names", []) | (sample && sample.names) || []]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)

    new_attrs = %{
      names: names,
      tags: extract_tags(attrs) ++ ((sample && sample.tags) || [])
    }

    Logger.debug("New attrs: #{inspect(new_attrs)}")

    update_sample(sample, new_attrs)
  end

  defp extract_tags(attrs) do
    [
      Map.get(attrs, "tags", []),
      Map.get(attrs, "type_tags", []),
      [Map.get(attrs, ["popular_threat_classification", "suggested_threat_label"], nil)],
      (Map.get(attrs, "popular_threat_category") || []) |> Enum.map(& &1["value"]),
      (Map.get(attrs, "popular_threat_name") || []) |> Enum.map(& &1["value"])
    ]
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  @doc """
  Queues all samples for VirusTotal processing
  """
  def queue_for_vt(opts) do
    list_samples(opts)
    |> Enum.each(fn sample ->
      %{
        "sha256" => sample.sha256,
        "is_new" => false,
        "is_first_request" => true
      }
      |> SubmitVt.new()
      |> Oban.insert()
    end)
  end

  def stream_samples_from_last_6_months(batch_size \\ 1000) do
    six_months_ago = DateTime.utc_now() |> DateTime.add(-180, :day)

    Sample
    |> where([s], s.inserted_at >= ^six_months_ago)
    |> order_by([s], s.id)
    |> select([s], s.sha256)
    |> VExchange.Repo.stream(max_rows: batch_size)
  end
end
