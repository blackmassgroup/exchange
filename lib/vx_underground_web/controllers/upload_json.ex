defmodule VxUndergroundWeb.UploadJSON do
  alias VxUnderground.Samples.Sample

  @doc """
  Renders a single user.
  """
  def show(%{sample: sample}) do
    %{data: data(sample)}
  end

  defp data(%Sample{} = sample) do
    %{
      id: sample.id
    }
  end
end
