defmodule Exchange.Repo.Local.Migrations.ImportTags do
  use Ecto.Migration

  # NimbleCSV.define(MyParser, separator: ",", escape: "\"")
  # ["04", "05", "06", "07", "08", "09", "10", "11", "12", "13"]

  def change do
    # Enum.map(["00", "03"], fn file ->
    # File.stream!("/Users/john/Desktop/tag_#{file}.csv")
    # NimbleCSV.define(MyParser, separator: ",", escape: "\"")

    # File.stream!("/Users/john/Desktop/tags/tag_00.csv")
    # |> MyParser.parse_stream()
    # |> Stream.map(fn [_id, tag_name, object_id] ->
    #   sample = Exchange.Samples.get_sample(object_id)
    #   Exchange.Samples.update_sample(sample, %{tags: [tag_name | sample.tags]})
    # end)
    # |> Enum.to_list()

    # split -l 10000000 -d tag.csv tag_ && for i in $(find tag_*); do mv $i "$i.csv"; done

    # end)
    # case Exchange.Samples.get_sample(object_id) do
    #   nil -> IO.inspect(object_id, label: :sample_does_not_exist)
    #   sample -> Exchange.Samples.update_sample(sample, %{tags: [tag_name | sample.tags]})
    # end
  end
end
