class Network
  
    def initialize(params={})
        params.each do |(key,value)|
            self.class.attr_accessor(key)
            send("#{key}=",value)
        end
    end
  
    @@networks=[]
    @@components=[]
    @@node=[]
   
    def self.start(bin_list) # This method is invoked whenever the position drops to -1
        if bin_list.all?{|a|a.tag=="read"} # Check if all interactions have been read
            puts "Fetched all interaction networks"
            return # if so, stop building the network.
        end
        puts "Starting new network" # If there are unread interactions left
        @@components=[] # initialize network pointers
        @@node=[]
        position=0
        new_start=bin_list.find{|pair|pair.tag=="unread"} # and fetch the first unread pair
        @@node[position]=new_start.id1
        start=@@node[position] # Set first member of binary interaction as the new start point
        @@components.append(start) # and add it to the components list
        position+=1 # point to next element
        @@node[position]=new_start.id2
        query=@@node[position] # Set second member of interaction as query for further steps,
        new_start.tag="read" # mark this interaction as read
        @@components.append(query) # and add this element to components list
        puts "start #{start} at position #{position-1}; query #{query} at position #{position}"
        Network.look_ahead(bin_list,query,position) # Pass arguments to builder method
        return
    end
    
    def self.look_ahead(bin_list,query,position) # This method is the actual builder of the network
        if position==-1 # Position drops to -1 when there are no unread interactors left.
            @@components.uniq! # Tidy up components list
            puts "Network complete with components:"
            puts @@components
            @@networks.append(Network.new({components:[@@components]})) # Create Network object and add it to the list
            Network.start(bin_list) # Try to start a new network
            return
        end
        if bin_list.none?{|u|u.tag=="unread"&&(u.id1==query||u.id2==query)} # If query is not found among unread interactions
            puts "Query #{query} not found at position #{position}"
            position-=1 # set pointer to previous position
            query=@@node[position] # and set node to previous node
            puts "Going back to node #{query} at position #{position}" # This is the actual brake function
            Network.look_ahead(bin_list,query,position) # Try to look for elements from the previous position
            return
        end
        puts "Querying from position #{position} for element #{query}"
        bin_list.each do |int| # If the above are false, parse interaction list and look for next node
            next if int.tag=="read" # Explicitly skip already read interactions,
            if int.id1==query # as valid potential interactions are only the unread ones
                current=@@node[position] # If a match is found, make it current node,
                position+=1 # point to the next node,
                @@node[position]=int.id2 # set next node as the other element of the pair
                query=@@node[position] # and set it to query in the next iteration
                int.tag="read" # Mark this interaction as read, so it will be skipped hereafter
                @@components.append(query) # and add query node to components list
                puts "New element #{int.id2} at position #{position}"
                Network.look_ahead(bin_list,query,position) # Try to look for elements ahead of this node
                return
            elsif int.id2==query # Same as above, but from the other side of the pair
                current=@@node[position]
                position+=1
                @@node[position]=int.id1
                query=@@node[position]
                int.tag="read"
                @@components.append(query)
                puts "New element #{int.id1} at position #{position}"
                Network.look_ahead(bin_list,query,position)
                return # Return blocks are essential
            end
        end
    end 

    def self.get # This method makes networks available as a local variable in main.rb
        puts "Networks complete"
        return @@networks
    end
    
end