require 'rubygems'
require 'faster_csv'

require '../data/import.rb'

class ImportCSV
	def import(start_path, csvfile, n)
		print "Base catalog [国内品牌]:"
		@@base_catalog = gets.chomp
		@@base_catalog = "国内品牌" if @@base_catalog.length < 1 	
	
		@@start_path = start_path
		i = 0
		csv_file = @@start_path + csvfile
		puts "CSV:" << csv_file
		FasterCSV.foreach(csv_file, :headers => true) do |row|
			parse_product(row)

		   i = i + 1
   		break if n>0 && i > n
   	end
	end
end

start_path = "../data/"
print "Start path [#{start_path}] :"
inp = gets.chomp
start_path = inp if inp.length > 0

csv_file = "out.csv"
print "CSV file [out.csv] :"
inp = gets.chomp
csv_file = inp if inp.length > 0

max_rec = "0"
print "Max import records [0=all] :"
inp = gets.chomp
max_rec = inp if inp.length > 0


a = ImportCSV.new
a.import(start_path, csv_file, max_rec.to_i)
