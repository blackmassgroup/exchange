defmodule VxUnderground.Services.VirusTotal do
  # https://developers.virustotal.com/reference/authentication
  @public_url ""
  @api_key System.get_env("VIRUS_TOTAL_API_KEY")

  def submit(_) do
    headers = [{"x-apikey", @api_key}]
    {:ok, conn} = Mint.HTTP.connect(:http, @public_url, 80)

    Mint.HTTP.request(conn, "GET", "/", headers, "")
  end
end
