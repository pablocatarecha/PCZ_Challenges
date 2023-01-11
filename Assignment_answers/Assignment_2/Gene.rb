class Gene
  
    def initialize(params={})
        params.each do |(key,value)|
            self.class.attr_accessor(key)
            send("#{key}=",value)
        end
    end
  
    @@agi_codes=[]

    def self.import(file)
        puts "Fetching agi codes from file"
        File.foreach(file) do |line|
            line=line.upcase.strip
            @@agi_codes.append(Gene.new({id:line}))
        end
        return @@agi_codes
    end
  
end