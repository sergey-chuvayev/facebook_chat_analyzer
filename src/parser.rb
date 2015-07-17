require 'nokogiri'
require 'htmlentities'
require 'sqlite3'


class Parser

	def main
		parse_file(get_file ARGV[0])
	end

	private

	def get_file(file)
		f = File.open(ARGV[0])
		doc = Nokogiri::HTML(f)
		return doc
	end

	def parse_file(doc)
		pwd = File.dirname(File.expand_path(__FILE__))
		db = SQLite3::Database.new "#{pwd}/facebook_parser.db"

		doc.css('.thread').last.css('.message').each_with_index do |message, i|
			message_text = message.next_element.text
			name = message.children().css('.user').text
			date = DateTime.parse(message.children().css('.meta').text).strftime('%Y-%m-%d %H:%M:%S')

			if db.execute('SELECT * FROM users WHERE users.name = ?', name).empty?
				db.execute("INSERT INTO users (name) 
					VALUES (?);", name)
			end

			user_id = db.execute('SELECT id FROM users WHERE users.name = ?', name)
			if db.execute('SELECT * FROM messages WHERE messages.message = ? AND messages.date = ?', message_text, date).empty?
				db.execute("INSERT INTO messages (user_id, message, date) 
					VALUES (?, ?, ?);", user_id, message_text, date)

				print "Processing message #{i+1}"
				print "\r"
			end

		end

		count = db.execute("SELECT count(*) FROM messages;")
		p "#{count} messages in database"
	end

end

parser = Parser.new
parser.main