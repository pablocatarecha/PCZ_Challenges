class Interaction
    
    def initialize(params={})
        params.each do |(key,value)|
            self.class.attr_accessor(key)
            send("#{key}=",value)
        end
    end
    
    @@raw_int=[]
    @@bin_int=[]
    @@bin_selected=[]
    
    def self.fetch_int(list)
        puts "Fetching interaction info from remote database. Please wait..."
        list.each do |locus|
            fetched_int=RestClient.get("http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{locus.id}")
            fetched_int.split("\n").each do |entry|
                @@raw_int.append(entry)
            end
        end
        return @@raw_int
    end
    
    def self.make_binary(raw_data,quality)
        puts "Building full binary interaction list"
        raw_data.each do |int|
            interactors=int.scan(/A[Tt]\d[Gg]\d\d\d\d\d/)
            interactors.map!(&:upcase).uniq!
            miscore=int.match(/intact-miscore:(0.\d\d)/)
            if int.split("\t")[9].include?("3702")&&int.split("\t")[10].include?("3702")&&miscore[1].to_f>quality
                if interactors.length==2
                    @@bin_int.append(Interaction.new({id1:interactors[0],id2:interactors[1],score:miscore[1].to_f,tag:"unread"}))
                elsif interactors.length==1
                    @@bin_int.append(Interaction.new({id1:interactors[0],id2:interactors[0],score:miscore[1].to_f,tag:"self"}))
                end
                puts "Added interaction between #{@@bin_int.last.id1} and #{@@bin_int.last.id2}, type #{@@bin_int.last.tag}"
            end
        end
        puts "Total interactions: #{@@bin_int.length}. Removing duplicates"
        @@bin_int.uniq!{|f|[f.id1,f.id2]}
        puts "Tagging reverse duplicates"
        @@bin_int.each do |element1|
            next unless element1.tag=="unread"
            @@bin_int.each do |element2|
                next unless element2.tag=="unread"
                if element1.id1==element2.id2&&element1.id2==element2.id1
                    element2.tag="skip"
                    puts "Skipping interaction between #{element2.id1} and #{element2.id2} in duplicate pair"
                    break
                end
            end
        end
        puts "Final interactions: #{@@bin_int.length}"
        return @@bin_int
    end

    def self.skim(bin_list)
        puts "Building shortlist for network discovery"
        @@bin_selected=bin_list.select{|pair| pair.tag=="unread"}
        return @@bin_selected
    end
    
end
