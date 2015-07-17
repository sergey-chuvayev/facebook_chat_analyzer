require 'sqlite3'

class Database

	pwd = File.dirname(File.expand_path(__FILE__))
	
	@db = SQLite3::Database.new "#{pwd}/facebook_parser.db"

	def self.create_db
		rows = @db.execute <<-SQL
			create table messages (
				id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				name varchar(30),
				date datetime default null,
				message text
			);
		SQL
	end

end
Database.create_db