class Stock
  attr_accessor :stock
  attr_accessor :id
  attr_accessor :date
  attr_accessor :bin
  attr_accessor :left
  
  @@stockdb = {}
  
  def initialize (stock:, id:, date:, bin:, left:)
    @stock = stock
    @id = id
    @date = date
    @bin = bin
    @left = left.to_i # Explicitly say this is an integer.
  end
  
  def self.load(stockfile)
    stocktable = CSV.read(stockfile, headers: true, col_sep: "\t")
    @stockheaders = stocktable.headers # Save headers to rebuild stockfile.
    stocktable.each() do |stockrow|
      @@stockdb[stockrow["Seed_Stock"]] = Stock.new(stock:stockrow["Seed_Stock"], id:stockrow["Mutant_Gene_ID"], date:stockrow["Last_Planted"], bin:stockrow["Storage"], left:stockrow["Grams_Remaining"])
    end
    return @@stockdb
  end
  
  def self.plant(grams)
    @@stockdb.each do |stockplant|
      if stockplant[1].left <= grams
        puts "We have ran out of seeds from stock #{stockplant[1].stock}"
        stockplant[1].left = 0
      else
        stockplant[1].left -= grams
      end
      stockplant[1].date = Date.today.strftime("%d/%m/%Y") # Update planting date.
    end
  end

  def self.updatestockdb(newstockfile)
    newstockheaders = @stockheaders.join("\t")
    File.write(newstockfile, "#{newstockheaders}\n", mode:'a')
    @@stockdb.each do |stockline|
      newstockline = ([stockline[1].stock, stockline[1].id, stockline[1].date, stockline[1].bin, stockline[1].left].join("\t"))
      File.write(newstockfile, "#{newstockline}\n", mode:"a")
    end
    puts "Seed data have been updated"
  end
  
  def self.fetchstock(queryp)
    @@stockdb.each do |lookedupstock|
      if lookedupstock[1].stock == queryp
        return Gene.fetchgene(lookedupstock[1].id)
      end
    end
  end

end
