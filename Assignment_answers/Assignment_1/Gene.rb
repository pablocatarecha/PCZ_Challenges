require 'csv' # Use of gem 'csv' is a suggestion from Pablo.

class Gene
  attr_accessor :id
  attr_accessor :name
  attr_accessor :phenotype
  attr_accessor :linkedto
  
  @@genedb = {} # Data will be stored in a hash as a set of pairs [key,object].
  
  def initialize (id:, name:, phenotype:, linkedto:)
    @id = id
    @name = name
    @phenotype = phenotype
    @linkedto = linkedto # Linkage information will be added to instances after analyzing linkage.
  end
  
  def self.load(genefile)
    genetable = CSV.read(genefile, headers: true, col_sep: "\t")
    genetable.each() do |generow| # Elements of the hash will be objects of class Gene, each with key "Gene_ID".
      @@genedb[generow["Gene_ID"]] = Gene.new(id:generow["Gene_ID"], name:generow["Gene_name"], phenotype:generow["mutant_phenotype"], linkedto: "Unknown")
    end
    return @@genedb
  end
  
  def self.checkid # See if IDs match regular Ath naming conventions.
    @@genedb.each do |gene|
      unless /A[Tt]\d[Gg]\d\d\d\d\d/ =~ gene[1].id # gene[1] extracts GeneObject from hash.
        puts "Error found in Gene_ID #{gene[1].id}. It seems it does not match the standard code. Exiting"
        exit 1
      end
    end
    puts "Seems all genes are properly named."
  end
  
  def self.fetchgene(queryid)
    @@genedb.each do |lookedupgene|
      if lookedupgene[1].id == queryid
        return lookedupgene[1]
      end
    end
  end
  
  def self.updatelinkage(name1,name2)
    @@genedb.each do |linkagefetch|
      if linkagefetch[1].name == name1
        linkagefetch[1].linkedto = name2
      elsif linkagefetch[1].name == name2
        linkagefetch[1].linkedto = name1
      end
    end
  end
    
end

