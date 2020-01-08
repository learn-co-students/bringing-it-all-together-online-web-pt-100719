class Dog

  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each do |key, value|
      self.send(("#{key}="), value)
      self.id ||= nil
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
  end

  def self.new_from_db(row)
    attributes_hash = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }
    self.new(attributes_hash)
  end

  def self.find_by_id(id) # Finds record using id
    sql = "SELECT * FROM dogs WHERE id = ?" # Selects record from dogs table where id equals what is passed in
    DB[:conn].execute(sql, id).map do |row| # Executes the SQL SELECT query with the value of id and maps each record with that id
      self.new_from_db(row)
    end.first # Returns the first record
  end

  def self.find_or_create_by(name:, breed:) # Finds record or creates it
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?" # SELECT query where name and breed must match an existing record

    dog = DB[:conn].execute(sql, name, breed).first # Local variable dog equals the value of our sql variable and the value of name and breed passed in. Selects the first one

    if dog
      new_dog = self.new_from_db(dog)
    else
      new_dog = self.create({:name => name, :breed => breed})
    end
    new_dog # Either way, display the value for new_dog
  end

  def self.find_by_name(name) # Finds record using a dog's name
    sql = "SELECT * FROM dogs WHERE name = ?" # Select command to find the matching dog
    DB[:conn].execute(sql, name).map do |row| # Calls upon the value for sql and executes it. Then iterates over each dog with the name
      self.new_from_db(row)
    end.first # Returns the first record of the dog with the matching name
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
