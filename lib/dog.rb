require 'pry'

class Dog
  attr_accessor :id, :name, :breed
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (id, name, breed) VALUES (?, ?, ?);
    SQL
    DB[:conn].execute(sql, id, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(id: nil, name:, breed:)
    Dog.new(id: id, name: name, breed: breed).save
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    new_dog_obj = DB[:conn].execute(sql, id)[0]
    self.new_from_db(new_dog_obj)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    new_dog_obj = DB[:conn].execute(sql, name)[0]
    self.new_from_db(new_dog_obj)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    new_dog = DB[:conn].execute(sql, name, breed)[0]
    new_dog.nil? ? self.create(name: name, breed: breed) : self.new_from_db(new_dog)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end