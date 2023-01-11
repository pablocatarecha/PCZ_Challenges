require 'rest-client'
require 'json'
require './Gene.rb'
require './Network.rb'
require './Interactions.rb'
require './Annotations.rb'

agi_codes=Gene.import("ArabidopsisSubNetwork_GeneList.txt")

raw_int=Interaction.fetch_int(agi_codes)

bin_int=Interaction.make_binary(raw_int,0.40)

bin_selected=Interaction.skim(bin_int)

Network.start(bin_selected)

networks=Network.get

rebuilt_networks=Annotations.build(networks)

annotated_networks=Annotations.get(rebuilt_networks,"GO")

annotated_networks=Annotations.get(rebuilt_networks,"KEGG")

puts "Saving report"

report=File.open('./Catarecha_BPC_Assignment2_report.txt',"w")

report.puts "******** Bioinformatics PRogramming Challenges"
report.puts "******** Assignment 2 - Intensive integration using web APIs"
report.puts "******** Pablo Catarecha"
report.puts "******** Report start"
report.puts "."
report.puts "*** #{bin_selected.length} interactions found between proteins in pairs:"
report.puts "id1\t\tid2"

bin_selected.each do |pair|
    report.puts "#{pair.id1}\t#{pair.id2}"
end

report.puts "."
report.puts "*** #{annotated_networks.length} networks found:"
report.puts "."

annotated_networks.each do |net|
    report.puts "**Network linked to gene #{net.net_id}"
    report.puts "."
    report.puts "#{net.components[0].length} network components:"
    report.puts net.components
    report.puts "."
    report.puts "GO processes related to this network:"
    report.puts "GO term ids:"
    report.puts net.GOterms
    report.puts "."
    report.puts "GO process names:"
    report.puts net.GOnames
    report.puts "."
    report.puts "KEGG pathways related to this network:"
    report.puts "KEGG pathway ids:"
    report.puts net.KEGGid
    report.puts "."
    report.puts "KEGG pathways:"
    report.puts net.KEGGpathways
    report.puts "."
end
report.puts "****** End of report."
report.close
puts "Report saved."