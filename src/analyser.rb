require 'sqlite3'

class Analyser
	pwd = File.dirname(File.expand_path(__FILE__))
	@db = SQLite3::Database.new "#{pwd}/facebook_parser.db"

	def self.output
		collection = self.rating
		out_str = ""
		collection.each do |c|
			out_str += "#{c[:user]}: #{c[:count]}\n"
		end
		# min_date = @db.execute("SELECT MIN(date) FROM messages;")
		# max_date = @db.execute("SELECT MAX(date) FROM messages;")
		# out_str = "From #{min_date} To #{max_date} \n #{out_str}"
		return out_str
	end


	def self.rating
		collection = []
		@db.execute("SELECT * FROM users").each do |user|
			count = @db.execute("SELECT COUNT(*) FROM messages WHERE messages.user_id = #{user[0]}")
			collection << {
				user: user[1],
				count: count[0][0].to_i
			}
		end
		return collection.sort_by {|obj| obj[:count]}.reverse
	end

end

p Analyser.output