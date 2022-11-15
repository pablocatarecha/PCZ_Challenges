class Cross
  attr_accessor :p1
  attr_accessor :p2
  attr_accessor :f2wt
  attr_accessor :f2p1
  attr_accessor :f2p2
  attr_accessor :f2double
  attr_accessor :chi2
  attr_accessor :linkage
 
  def initialize(p1:, p2:, f2wt:, f2p1:, f2p2:, f2double:, chi2:, linkage:)
    @p1 = p1
    @p2 = p2
    @f2wt = f2wt.to_f # Further calculation will include divisions, so this value should be set to float.
    @f2p1 = f2p1.to_f
    @f2p2 = f2p2.to_f
    @f2double = f2double.to_f
    @chi2 = chi2.to_f
    @linkage = linkage
  end
  
  @@crossdb = {}
  
  def self.load(crossfile)
    crosstable = CSV.read(crossfile, headers: true, col_sep: "\t")
    crosstable.each() do |crossrow|
      crossobjectname = "Cross_" + crossrow["Parent1"] + "x" + crossrow["Parent2"] # Object names in class Cross resemble the actual cross.
      @@crossdb[crossobjectname] = Cross.new(p1:crossrow["Parent1"], p2:crossrow["Parent2"], f2wt:crossrow["F2_Wild"], f2p1:crossrow["F2_P1"], f2p2:crossrow["F2_P2"], f2double:crossrow["F2_P1P2"], chi2: nil, linkage:"Unknown")
    end
    return @@crossdb
  end
  
  def self.analyze
    @@crossdb.each do |crossanalysis| # Here are the calculations for chi-square.
      allf2 = crossanalysis[1].f2wt + crossanalysis[1].f2p1 + crossanalysis[1].f2p2 + crossanalysis[1].f2double
      expwt = 9 * allf2 / 16
      expp1 = 3 * allf2 / 16
      expp2 = 3 * allf2 / 16
      expdouble = allf2 / 16
      chi2 = (((crossanalysis[1].f2wt-expwt)**2/expwt)+((crossanalysis[1].f2p1-expp1)**2/expp1)+((crossanalysis[1].f2p2-expp2)**2/expp2)+((crossanalysis[1].f2double-expdouble)**2/expdouble))
      crossanalysis[1].chi2 = chi2
      if chi2 > 7.815 # This is the chi-square value to reject null hypothesis at 95% confidence and 3 degrees of freedom
        crossanalysis[1].linkage = "Confirmed"
        puts "Here are the results of #{crossanalysis[0]}: #{crossanalysis[1].linkage}"
        puts "#{crossanalysis[1].p1} is linked to #{crossanalysis[1].p2}"
      end
    end
  end
  
  def self.linkagenames
    @@crossdb.each do |queryp|
      if queryp[1].linkage = "Confirmed"
        @parental1 = Stock.fetchstock(queryp[1].p1).name
        @parental2 = Stock.fetchstock(queryp[1].p2).name
      end
    end
    puts "#{@parental1} is linked to #{@parental2}"
    Gene.updatelinkage(@parental1,@parental2)
  end
  
end
