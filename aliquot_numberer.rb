# NAME:	FreezerPro_aliquot.rb
# AUTHOR: Henrik Vestin Uppsala Biobank
# DATE: 2026 06 24
# HISTORY: 1.04
#		   
#		   
# COMMENT: Utgå från FreezerPro rapport för att skapa alikvotnumrering.
#
#==================================================================


require 'csv'

input_file = './Fil1_innan_numerering.csv'
output_file = './Fil1_numrering_klar.csv'
#Same input and output filename should be avoided

aliquot = 0 #this will increment before first assignment
key_lookup = {}  # Hash acting as lookup table
rows = []
headers = nil

CSV.foreach(input_file, col_sep: ';', headers: true) do |row|
  headers ||= row.headers + (row.headers.include?('ALIQUOT') ? [] : ['ALIQUOT']) #Check if there is an ALIQUOT column otherwise add it

  current_key = row['(NOPHO) Provnummer']&.strip #Column for key value

  if key_lookup.key?(current_key)
    #Same key: reuse stored aliquot value
    assigned = key_lookup[current_key]
  else
    #New key: increment aliquot and store ut
    aliquot += 1
    key_lookup[current_key] = aliquot
    assigned = aliquot
    # Check if any other key already has this aliquot number
    duplicates = key_lookup.select { |k, v| v == aliquot && k != current_key }
    puts "COLLISION: #{current_key.inspect} got aliquot #{aliquot}, but so does #{duplicates.inspect}" unless duplicates.empty?

  end

  row['ALIQUOT'] = assigned # Assign value to ALIQUOT column
  rows << row.fields
end
#Just to make sure that the table and counter are the same size.
puts "LOOKUP SIZE: #{key_lookup.size}, ALIQUOT COUNTER: #{aliquot}"

CSV.open(output_file, 'w', col_sep: ';') do |csv|
    csv << headers
    rows.each { |row| csv << row }
  end

puts "Done! ALIQUOT nr written to #{output_file}"
