require 'sqlite3'

class Analyser
	pwd = File.dirname(File.expand_path(__FILE__))
	@db = SQLite3::Database.new "#{pwd}/facebook_parser.db"

	def self.main
		str = ""
		words_rating.each do |words|
			str += "#{words[:name][0][0]}: #{words[:count]}\n"
		end
		min_date = get_min_max('MIN')
		max_date = get_min_max('MAX')
		str = "From #{min_date} To #{max_date} \n#{str}"
		return str
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
		return DateTime.parse(@db.execute("SELECT #{minormax}(date) FROM messages;")[0][0]).strftime('%D')
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

	def self.words_rating
		collection = []
		@db.execute("SELECT * FROM users").each do |user|
			messages = @db.execute("SELECT * FROM messages WHERE messages.user_id = #{user[0]}")
			messages.each do |message|
				name = @db.execute("SELECT name FROM users WHERE users.id = #{message[1]}")
				one_message_count = message[3].split(' ').count
				collection << {
					name: name,
					count: one_message_count
				}
			end
		end

		for j in 0..collection.count - 2
			i = j+1
			loop do
				if i > collection.length-1
					break
				end
				if collection[j][:name] == collection[i][:name]
					collection[j][:count] += collection[i][:count]
					collection.delete_at(i)
				else
					i+=1
				end	
			end
		end

		return collection.sort_by {|obj| obj[:count]}.reverse
	end

end

puts Analyser.main