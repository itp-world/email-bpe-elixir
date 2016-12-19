defmodule BPE.Recipient do
  defstruct [:id, :email, :name, :statuses, :eml, :sendat, :template_data]

  def from_params(params) do
    %BPE.Recipient{
      id: params["id"],
      email: params["email"],
      name: params["name"],
      statuses: params["statuses"],
      eml: params["eml"],
      sendat: params["sendat"],
      template_data: params["template_data"]
    }
  end

  def create(recipient) do
    {:ok, result} = Mongo.insert_one(BPE.MongodbPool, "recipients", recipient)
    str_id = Base.encode16(result.inserted_id.value, case: :lower)
    Map.put(recipient, :id, str_id)
  end

  def read(recipient_id) do
    obj_id = %BSON.ObjectId{value: Base.decode16!(recipient_id, case: :lower)}
    result = Mongo.find(BPE.MongodbPool, "recipients", %{_id: obj_id}, limit: 1)
      |> Enum.to_list
      |> List.first
      |> Map.drop([:_id, "_id"])
    Map.merge(%BPE.Recipient{id: recipient_id}, result)
  end

  def update(recipient_id, attributes) do
    obj_id = %BSON.ObjectId{value: Base.decode16!(recipient_id, case: :lower)}
    Mongo.update_one(BPE.MongodbPool, "recipients", %{_id: obj_id}, %{"$set": attributes})
  end

  #def delete do
  #end

end
