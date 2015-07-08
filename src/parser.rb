require 'nokogiri'
require 'htmlentities'

f = File.open(ARGV[0])
doc = Nokogiri::XML(f)
names = Hash.new(0)
to = doc.css('.thread').last.css('.meta').first.inner_html
from = doc.css('.thread').last.css('.meta').last.inner_html

doc.css('.thread').last.css('.user').each_with_index do |u, i|
	names[HTMLEntities.new.decode(u.inner_html)] += 1
	print "#{i+1} messages processed"
	print "\r"
end

sorted = names.sort_by{|_, v| v}.reverse
str = "From #{from} to #{to}\n"
sorted.each_with_index do |s, i|
	str += "#{i+1} #{s[0]} #{s[1]}\n"
end
puts str
File.open("#{from} - #{to}.txt", "w") { |file| file.write(str) }
f.close