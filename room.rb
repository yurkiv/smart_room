class Room < Ohm::Model
  attribute :name
  attribute :available

  index :name

  def serialize
    {
      id: id,
      name: name,
      available: available
    }
  end
end