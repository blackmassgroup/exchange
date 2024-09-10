defmodule Exchange.CleanHashesTest do
  use Exchange.DataCase

  alias Exchange.CleanHashes

  describe "clean_hashes" do
    alias Exchange.CleanHashes.CleanHash

    import Exchange.CleanHashesFixtures

    @invalid_attrs %{sha256: nil}

    test "list_clean_hashes/0 returns all clean_hashes" do
      clean_hash = clean_hash_fixture()
      assert CleanHashes.list_clean_hashes() == [clean_hash]
    end

    test "get_clean_hash!/1 returns the clean_hash with given id" do
      clean_hash = clean_hash_fixture()
      assert CleanHashes.get_clean_hash!(clean_hash.id) == clean_hash
    end

    test "create_clean_hash/1 with valid data creates a clean_hash" do
      valid_attrs = %{sha256: "some sha256"}

      assert {:ok, %CleanHash{} = clean_hash} = CleanHashes.create_clean_hash(valid_attrs)
      assert clean_hash.sha256 == "some sha256"
    end

    test "create_clean_hash/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CleanHashes.create_clean_hash(@invalid_attrs)
    end

    test "update_clean_hash/2 with valid data updates the clean_hash" do
      clean_hash = clean_hash_fixture()
      update_attrs = %{sha256: "some updated sha256"}

      assert {:ok, %CleanHash{} = clean_hash} = CleanHashes.update_clean_hash(clean_hash, update_attrs)
      assert clean_hash.sha256 == "some updated sha256"
    end

    test "update_clean_hash/2 with invalid data returns error changeset" do
      clean_hash = clean_hash_fixture()
      assert {:error, %Ecto.Changeset{}} = CleanHashes.update_clean_hash(clean_hash, @invalid_attrs)
      assert clean_hash == CleanHashes.get_clean_hash!(clean_hash.id)
    end

    test "delete_clean_hash/1 deletes the clean_hash" do
      clean_hash = clean_hash_fixture()
      assert {:ok, %CleanHash{}} = CleanHashes.delete_clean_hash(clean_hash)
      assert_raise Ecto.NoResultsError, fn -> CleanHashes.get_clean_hash!(clean_hash.id) end
    end

    test "change_clean_hash/1 returns a clean_hash changeset" do
      clean_hash = clean_hash_fixture()
      assert %Ecto.Changeset{} = CleanHashes.change_clean_hash(clean_hash)
    end
  end
end
