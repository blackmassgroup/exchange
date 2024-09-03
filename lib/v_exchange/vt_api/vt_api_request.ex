defmodule VExchange.VtApi.VtApiRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vt_api_requests" do
    field :raw_request, :string
    field :raw_response, :string
    field :http_response_code, :integer
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(vt_api_request, attrs) do
    vt_api_request
    |> cast(attrs, [:raw_request, :raw_response, :http_response_code, :url])
    |> validate_required([:raw_request, :url])
  end
end
