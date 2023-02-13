defmodule VxUnderground.Services.Triage do
  @public_url "https://tria.ge/api/v0/"
  @private_cloud_url "https://private.tria.ge/api/v0/"
  @recorded_future_sandbox_url "https://sandbox.recordedfuture.com/api/v0/"

  @api_key System.get_env("TRIAGE_API_KEY")

  #
  # Authentication
  # https://tria.ge/docs/faq/
  # https://tria.ge/docs/cloud-api/conventions/#authentication
  #
  # Submission
  # https://tria.ge/docs/cloud-api/submit/
  # https://tria.ge/docs/cloud-api/samples/#post-samples
  #


  def submit(_url) do
    # {:ok, conn, ref} = Mint.HTTP.request(conn, "GET", "/foo", [], "")
    # {:ok, conn, ref} = Mint.HTTP.request(conn, "GET", "/bar", [], "")
    :ok
  end
end
