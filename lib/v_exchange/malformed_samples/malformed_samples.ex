defmodule VExchange.MalformedSamples do
  @moduledoc """
  The MalformedSamples context.
  """

  import Ecto.Query, warn: false
  alias VExchange.Repo

  alias VExchange.MalformedSamples.MalformedSample

  @doc """
  Returns the list of malformed_samples.

  ## Examples

      iex> list_malformed_samples()
      [%MalformedSample{}, ...]

  """
  def list_malformed_samples do
    Repo.all(MalformedSample)
  end

  @doc """
  Gets a single malformed_sample.

  Raises `Ecto.NoResultsError` if the Malformed sample does not exist.

  ## Examples

      iex> get_malformed_sample!(123)
      %MalformedSample{}

      iex> get_malformed_sample!(456)
      ** (Ecto.NoResultsError)

  """
  def get_malformed_sample!(id), do: Repo.get!(MalformedSample, id)

  @doc """
  Creates a malformed_sample.

  ## Examples

      iex> create_malformed_sample(%{field: value})
      {:ok, %MalformedSample{}}

      iex> create_malformed_sample(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_malformed_sample(attrs \\ %{}) do
    %MalformedSample{}
    |> MalformedSample.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a malformed_sample.

  ## Examples

      iex> update_malformed_sample(malformed_sample, %{field: new_value})
      {:ok, %MalformedSample{}}

      iex> update_malformed_sample(malformed_sample, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_malformed_sample(%MalformedSample{} = malformed_sample, attrs) do
    malformed_sample
    |> MalformedSample.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a malformed_sample.

  ## Examples

      iex> delete_malformed_sample(malformed_sample)
      {:ok, %MalformedSample{}}

      iex> delete_malformed_sample(malformed_sample)
      {:error, %Ecto.Changeset{}}

  """
  def delete_malformed_sample(%MalformedSample{} = malformed_sample) do
    Repo.delete(malformed_sample)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking malformed_sample changes.

  ## Examples

      iex> change_malformed_sample(malformed_sample)
      %Ecto.Changeset{data: %MalformedSample{}}

  """
  def change_malformed_sample(%MalformedSample{} = malformed_sample, attrs \\ %{}) do
    MalformedSample.changeset(malformed_sample, attrs)
  end

  alias VExchange.ObanJobs.CleanSamples

  @batch_size 10_000

  def queue_jobs do
    VExchange.Repo.transaction(
      fn ->
        VExchange.Samples.stream_samples_from_last_6_months(@batch_size)
        |> Stream.chunk_every(1000)
        |> Stream.each(fn chunk ->
          jobs = Enum.map(chunk, &%{sha256: &1})
          {:ok, _} = Oban.insert_all(CleanSamples, jobs)
        end)
        |> Stream.run()
      end,
      timeout: :infinity
    )
  end
end
