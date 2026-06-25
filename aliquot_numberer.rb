# NAME:	FreezerPro_aliquot.rb
# AUTHOR: Henrik Vestin Uppsala Biobank
# DATE: 2026 06 24
# HISTORY: 1.03
#		   
#		   
# COMMENT: Utgå från FreezerPro rapport för att skapa alikvotnumrering.
#
#==================================================================


require 'csv'

input_file = './csv/UBB-xx.csv'
output_file = './csv/UBB-yy.csv'
#Same filename should be safe to use, but be careful

aliquot = 0 #this will increment before first assignment
key_lookup = {}  # Hash acting as lookup table
rows = []
headers = nil

CSV.foreach(input_file, col_sep: ';', headers: true) do |row|
  headers ||= row.headers + (row.headers.include?('ALIQUOT') ? [] : ['ALIQUOT'])

  current_key = row['(NOPHO) Provnummer'] #Column for key value

  if key_lookup.key?(current_key)
    #Same key: reuse stored aliquot value
    aliquot = key_lookup[current_key]
  else
    #New key: increment aliquot and store ut
    aliquot += 1
    key_lookup[current_key] = aliquot
    puts current_key
  end

  row['ALIQUOT'] = aliquot # Assign aliquot to index 2 i.e column 3
  rows << row.fields
end

  CSV.open(output_file, 'w', col_sep: ';') do |csv|
    csv << headers
    rows.each { |row| csv << row }
  end

puts "Done! ALIQUOT nr written to #{output_file}"
