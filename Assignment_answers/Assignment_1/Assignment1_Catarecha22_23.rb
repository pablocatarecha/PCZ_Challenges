require './Gene.rb'
require './Stock.rb'
require './Cross.rb'

genedb = Gene.load('gene_information.tsv') # Initial files are already set to the ones provided.
Gene.checkid # Making sure all IDs are properly written.

stockdb = Stock.load('seed_stock_data.tsv')
Stock.plant(7) # Planting some grams.
Stock.updatestockdb('updated_seed_data.tsv') # Writing updated stock info.

crossdb = Cross.load('cross_data.tsv')
Cross.analyze # Chi-square calculations on crosses data.
Cross.linkagenames # Fetch actual gene names and update genesdb.
