require 'rubygems'
require 'faster_csv'

print "CSV:"
csv_file = gets.chomp

		FasterCSV.foreach(csv_file, :headers => true) do |row|
			puts row
   	end
