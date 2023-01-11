class Annotations

    def initialize(params={})
        params.each do |(key,value)|
            self.class.attr_accessor(key)
            send("#{key}=",value)
        end
    end

    @@annotated_networks=[]

    def self.build(networks) # Make simple annotator object. It will be dynamically filled afterwards
        networks.each do |net|
            rebuild=[]
            comparr=net.components[0]
            net_rep=net.components[0][0]
            @@annotated_networks.append(Annotations.new({net_id:net_rep,components:[comparr]}))
        end
        return @@annotated_networks # Now networks are Annotations objects
    end

    def self.get(networks,db) # General annotation method
        if db=="GO" # In this assignment, only GO and KEGG databases are used
            Annotations.new(GOterms:nil,GOnames:nil) # Initialize attributes. This is specific to db
            networks.each do |net|
                puts "Opening elements of new network"
                names=[]
                terms=[]
                net.components[0].each do |component|
                    puts "Fetching GO terms for #{component}"
                    response=RestClient::Request.execute({ # Straight from lectures
                        method: :get,
                        url: "http://togows.dbcls.jp/entry/uniprot/#{component}/dr.json"
                    })
                    data = JSON.parse(response.body)
                    data[0]['GO'].each do |line|
                        if line[1] =~ /^P:/ # This selects biological processes
                            terms.append(line[0])
                            names.append(line[1])
                        end
                    end
                end
                net.GOterms=terms.uniq! # Fill void attributes with data
                net.GOnames=names.uniq!
            end
        end
        if db=="KEGG" # Same as with GO. Additional 'if' statements can be included to expand this method
            Annotations.new(KEGGid:nil,KEGGpathways:nil) # KEGG-specific attributes
            networks.each do |net|
                puts "Opening elements of new network"
                id=[]
                path=[]
                net.components[0].each do |component|
                    puts "Fetching KEGG pathways for #{component}"
                    response=RestClient::Request.execute({
                        method: :get,
                        url: "http://togows.org/entry/kegg-genes/ath:#{component}/pathways.json"
                    })
                    data = JSON.parse(response.body)
                    data[0].each do |line| # JSON structure is slightly different
                        id.append(line[0])
                        path.append(line[1])
                    end
                end
                net.KEGGid=id.uniq!
                net.KEGGpathways=path.uniq!
            end
        end
        return networks
    end

end