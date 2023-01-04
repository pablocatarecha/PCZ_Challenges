require 'bio'
puts "Opening A. thaliana cds database."
arath_db=Bio::FastaFormat.open('./TAIR10_cds_20101214_updated.fa') # Both databases are provided in Fasta format.
# Given that A. thaliana database is provided as a collection of cds, I will translate it
# to make a protein database. This will allow for regular blastp queries, instead of
# translated tblastn or blastx methods, which require more computational power.
# This trick cannot be done whenever the nucleotide database is not restricted, of course.
puts "Building translated database for A. thaliana. Please wait..."
tdata=File.open('./Arath_tr.fa',"w") # File to store A. thaliana protein database.
arath_db.each do |x| # Bio::FastaFormat objects use several methods to manipulate entries.
  tdata.puts (">#{x.entry_id}")
  tdata.puts (Bio::Sequence.auto(x.seq.to_s).translate) # Actual sequence is treated as a Bio::Sequence object.
end
tdata.close
puts "Done."
puts "Opening S. pombe peptide database."
sacpo_db=Bio::FastaFormat.open('./pep.fa')
puts "Making databases. Please wait..."
system("mkdir Databases") # BLAST databases will be of the 'protein' type.
system("makeblastdb -in Arath_tr.fa -dbtype prot -out Databases/athdb")
system("makeblastdb -in pep.fa -dbtype prot -out Databases/spodb")
puts "Building BLAST factories." # Results are filtered according to e-value and sorted according to bit_score.
ath_fact=Bio::Blast.local('blastp',"./Databases/athdb"," -e 10e-6 -sorthits 1")
spo_fact=Bio::Blast.local('blastp',"./Databases/spodb"," -e 10e-6 -sorthits 1")
puts "Starting BLAST reciprocal search. Go grab a coffee..."
brh=File.open('./Best_reciprocal_hits.txt',"w") # File where best reciprocal hits will be stored.
brh.puts("Reciprocal hits found:")
brh.puts("S. pombe\tA. thaliana")
sacpo_db.each do |spo_q| # Parse S. pombe database.
  result=ath_fact.query(spo_q.seq) # BLAST each sequence to A. thaliana database.
  next if result.hits.empty? # Skip to next entry if BLAST results are empty,
  next if result.hits.first.bit_score<50 # or score is too low.
  puts spo_q.entry_id # Printing some info on screen to avoid getting impatient.
  puts result.hits.first.target_def
  puts
  arath_db_tr=Bio::FastaFormat.open('./Arath_tr.fa') # For some reason, I have to re-open this every time.
  arath_db_tr.each do |ath_q| # S. pombe entries that pass the conditions trigger parsing of A. thaliana database.
    next unless ath_q.entry_id==result.hits.first.target_def # Skip all A. thaliana entries that don't match BLAST target.
    result_back=spo_fact.query(ath_q.seq) # When the target is found, BLAST back A. thaliana sequences to S. pombe database.
    next if result_back.hits.empty? # Same filters as above
    next if result_back.hits.first.bit_score<50
    puts ath_q.entry_id
    puts result_back.hits.first.target_def.split("|")[0]
    puts "..." # On screen you will have forward and reverse best hits up to this point.
    break unless spo_q.entry_id==result_back.hits.first.target_def.split("|")[0] # Stop parsing the database unless best hits are reciprocal.
    puts "Reciprocal hit found between #{spo_q.entry_id} and #{result.hits.first.target_def}." # Print some good news on screen,
    puts "..."
    brh.puts("#{spo_q.entry_id}\t#{result.hits.first.target_def}") # and store it in results file.
    break # Now stop iterating for this target.
  end
end
brh.close
puts "Script end. Have a nice day."
