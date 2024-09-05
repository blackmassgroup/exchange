defmodule VExchange.MalformedSamplesTest do
  use VExchange.DataCase

  alias VExchange.MalformedSamples

  describe "malformed_samples" do
    alias VExchange.MalformedSamples.MalformedSample

    import VExchange.MalformedSamplesFixtures

    @invalid_attrs %{sha256: nil}

    test "list_malformed_samples/0 returns all malformed_samples" do
      malformed_sample = malformed_sample_fixture()
      assert MalformedSamples.list_malformed_samples() == [malformed_sample]
    end

    test "get_malformed_sample!/1 returns the malformed_sample with given id" do
      malformed_sample = malformed_sample_fixture()
      assert MalformedSamples.get_malformed_sample!(malformed_sample.id) == malformed_sample
    end

    test "create_malformed_sample/1 with valid data creates a malformed_sample" do
      valid_attrs = %{sha256: "some sha256"}

      assert {:ok, %MalformedSample{} = malformed_sample} = MalformedSamples.create_malformed_sample(valid_attrs)
      assert malformed_sample.sha256 == "some sha256"
    end

    test "create_malformed_sample/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MalformedSamples.create_malformed_sample(@invalid_attrs)
    end

    test "update_malformed_sample/2 with valid data updates the malformed_sample" do
      malformed_sample = malformed_sample_fixture()
      update_attrs = %{sha256: "some updated sha256"}

      assert {:ok, %MalformedSample{} = malformed_sample} = MalformedSamples.update_malformed_sample(malformed_sample, update_attrs)
      assert malformed_sample.sha256 == "some updated sha256"
    end

    test "update_malformed_sample/2 with invalid data returns error changeset" do
      malformed_sample = malformed_sample_fixture()
      assert {:error, %Ecto.Changeset{}} = MalformedSamples.update_malformed_sample(malformed_sample, @invalid_attrs)
      assert malformed_sample == MalformedSamples.get_malformed_sample!(malformed_sample.id)
    end

    test "delete_malformed_sample/1 deletes the malformed_sample" do
      malformed_sample = malformed_sample_fixture()
      assert {:ok, %MalformedSample{}} = MalformedSamples.delete_malformed_sample(malformed_sample)
      assert_raise Ecto.NoResultsError, fn -> MalformedSamples.get_malformed_sample!(malformed_sample.id) end
    end

    test "change_malformed_sample/1 returns a malformed_sample changeset" do
      malformed_sample = malformed_sample_fixture()
      assert %Ecto.Changeset{} = MalformedSamples.change_malformed_sample(malformed_sample)
    end
  end
end
