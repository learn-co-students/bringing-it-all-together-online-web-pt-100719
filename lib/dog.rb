class Dog

    attr_accessor :id, :name, :breed

    def initialize (hash)
        hash.each {|k, v| self.send("#{k}=", v)}
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
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
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
        hash = {
            :id => row[0],
            :name => row[1],
            :breed => row[2],
        }
        self.new(hash)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
        SQL
  
  
        dog = DB[:conn].execute(sql, name, breed).first
  
        if dog
          new_dog = self.new_from_db(dog)
        else
          new_dog = self.create({:name => name, :breed => breed})
        end
        new_dog
    end 
        #sql = <<-SQL
         #   SELECT * FROM dogs
          #  WHERE name = ? AND breed = ?
        #SQL

        #dog = DB[:conn].execute(sql, name, breed).first
        #if !dog.empty?
         #   dog_data = self.new_from_db(dog)
        #else
        #    dog_data = self.create(name: name, breed: breed)
        #end
        #dog_data
    
    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ?"
        DB[:conn].execute(sql, self.name, self.breed)
    end
end