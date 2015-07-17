require 'sqlite3'

class Analyser
	pwd = File.dirname(File.expand_path(__FILE__))
	@db = SQLite3::Database.new "#{pwd}/facebook_parser.db"

	def self.main
		output(messages_rating)
	end

	private

	def self.output(collection)
		out_str = ""
		collection.each do |c|
			out_str += "#{c[:user]}: #{c[:count]}\n"
		end
		min_date = get_min_max('MIN')
		max_date = get_min_max('MAX')
		out_str = "From #{min_date} To #{max_date} \n#{out_str}"
		return out_str
	end

	def self.get_min_max(minormax)
		return DateTime.parse(@db.execute("SELECT #{minormax}(date) FROM messages;")[0][0])
	end

	def self.messages_rating
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

	# def self.words_rating
	# 	collection = []
	# 	@db.execute("SELECT * FROM users").each do |user|
	# 		count = @db.execute("SELECT COUNT(*) FROM messages WHERE messages.user_id = #{user[0]}")
	# 		collection << {
	# 			user: user[1],
	# 			count: count[0][0].to_i
	# 		}
	# 	end
	# 	return collection.sort_by {|obj| obj[:count]}.reverse
	# end

end

puts Analyser.main