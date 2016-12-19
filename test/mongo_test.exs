defmodule Mongo.Test do
  use MongoTest.Case, async: true

  defmodule Pool do
    use Mongo.Pool, name: __MODULE__, adapter: Mongo.Pool.Poolboy
  end

  setup_all do
    assert {:ok, _} = Pool.start_link(database: "bpe_test")
    Mongo.delete_many(Pool, "recipients", %{})
    :ok
  end

  test "count" do
    assert 0 = Mongo.count(Pool, "recipients", [])
  end

  test "insert_and_delete_one" do
    assert 0 = Mongo.count(Pool, "recipients", [])
    assert {:ok, result} = Mongo.insert_one(Pool, "recipients", %BPE.Recipient{
      id: "1234",
      email: "test@example.org",
      name: "test",
      status: "tested",
      eml: "testeml"
    })
    assert %Mongo.InsertOneResult{inserted_id: id} = result
    assert {:ok, %Mongo.DeleteResult{deleted_count: 1}} = Mongo.delete_one(Pool, "recipients", %{_id: id})
    assert 0 = Mongo.count(Pool, "recipients", [])
  end

  test "find_recipient" do
    recipient = %BPE.Recipient{
      id: "1234",
      email: "test@example.org",
      name: "test",
      status: "tested",
      eml: "testeml"
    }
    assert {:ok, result} = Mongo.insert_one(Pool, "recipients", recipient)
    assert %Mongo.InsertOneResult{inserted_id: id} = result
    assert [recipient] = Mongo.find(Pool, "recipients", %{id: "1234"}, batch_size: 1) |> Enum.to_list
    Mongo.delete_one(Pool, "recipients", %{_id: id})
  end

  test "run_command with an error" do
    assert_raise Mongo.Error, fn ->
      Mongo.run_command(Pool, %{ drop: "unexisting-database" })
    end
  end
end
