class MForwd::DataModel::Item < Sequel::Model(:items)
  def encode
    stash = {}
    self.columns.each do |col|
      next if col == 'id' or col == :id
      stash[col] = self.send(col)
    end
    stash
  end

  def self.decode data
    new JSON.parse(data)
  end
end
