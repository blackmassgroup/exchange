defmodule VxUnderground.SamplesTest do
  use VxUnderground.DataCase

  alias VxUnderground.Samples

  @tag :skip
  describe "samples" do
    alias VxUnderground.Samples.Sample

    import VxUnderground.SamplesFixtures

    @invalid_attrs %{
      first_seen: nil,
      hash: nil,
      s3_object_key: nil,
      size: nil,
      tags: [%VxUnderground.Tags.Tag{name: "Test"}],
      type: nil
    }

    test "list_samples/0 returns all samples" do
      sample = sample_fixture()
      assert Samples.list_samples() == [sample]
    end

    test "get_sample!/1 returns the sample with given id" do
      sample = sample_fixture()
      assert Samples.get_sample!(sample.id) == sample
    end

    @tag :skip
    test "create_sample/1 with valid data creates a sample" do
      valid_attrs = %{
        first_seen: ~U[2023-02-04 17:21:00Z],
        hash: "some hash",
        s3_object_key: "some s3_object_key",
        size: 42,
        tags: [%VxUnderground.Tags.Tag{name: "Test"}, 2],
        type: "some type"
      }

      assert {:ok, %Sample{} = sample} = Samples.create_sample(valid_attrs)
      assert sample.first_seen == ~U[2023-02-04 17:21:00Z]
      assert sample.hash == "some hash"
      assert sample.s3_object_key == "some s3_object_key"
      assert sample.size == 42

      assert sample.tags == [
               %VxUnderground.Tags.Tag{
                 id: nil,
                 kind: nil,
                 name: "Test",
                 inserted_at: nil,
                 updated_at: nil
               },
               2
             ]

      assert sample.type == "some type"
    end

    test "create_sample/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Samples.create_sample(@invalid_attrs)
    end

    @tag :skip
    test "update_sample/2 with valid data updates the sample" do
      sample = sample_fixture()

      update_attrs = %{
        first_seen: ~U[2023-02-05 17:21:00Z],
        hash: "some updated hash",
        s3_object_key: "some updated s3_object_key",
        size: 43,
        tags: [%VxUnderground.Tags.Tag{name: "Test"}],
        type: "some updated type"
      }

      assert {:ok, %Sample{} = sample} = Samples.update_sample(sample, update_attrs)
      assert sample.first_seen == ~U[2023-02-05 17:21:00Z]
      assert sample.hash == "some updated hash"
      assert sample.s3_object_key == "some updated s3_object_key"
      assert sample.size == 43
      assert sample.tags == [1]
      assert sample.type == "some updated type"
    end

    test "update_sample/2 with invalid data returns error changeset" do
      sample = sample_fixture()
      assert {:error, %Ecto.Changeset{}} = Samples.update_sample(sample, @invalid_attrs)
      assert sample == Samples.get_sample!(sample.id)
    end

    test "delete_sample/1 deletes the sample" do
      sample = sample_fixture()
      assert {:ok, %Sample{}} = Samples.delete_sample(sample)
      assert_raise Ecto.NoResultsError, fn -> Samples.get_sample!(sample.id) end
    end

    test "change_sample/1 returns a sample changeset" do
      sample = sample_fixture()
      assert %Ecto.Changeset{} = Samples.change_sample(sample)
    end
  end
end
