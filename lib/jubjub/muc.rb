require 'jubjub/data_form'

module Jubjub
  class Muc
    
    attr_reader :jid, :name
    
    def initialize(jid, name = nil, connection = nil)
      @jid = Jubjub::Jid.new(jid)
      @name = name
      @connection = connection
    end 
    
    def exit(nick = nil)
      full_jid = Jubjub::Jid.new @jid.node, @jid.domain, nick || @connection.jid.node
      
      @connection.muc.exit(full_jid)
      self
    end
    
    def destroy
      @connection.muc.destroy(@jid)
    end
    
    # Hide the connection details and show jid as string for compactness
    def inspect
      obj_id = "%x" % (object_id << 1)
      "#<#{self.class}:0x#{obj_id} @jid=\"#{@jid}\" @name=#{@name.inspect}>"
    end
    
  end
  
  # Uses proxy pattern for syntax sugar
  # and delaying expensive operations until
  # required
  class MucCollection
     
    attr_reader :jid
     
    def initialize(jid, connection)
      @jid = Jubjub::Jid.new(jid)
      @connection = connection
    end
    
    def create(node, nick = nil, &block)
      full_jid = Jubjub::Jid.new node, @jid.domain, nick || @connection.jid.node

      if block_given?
        # Reserved room
        config = @connection.muc.configuration full_jid
        yield config
        @connection.muc.create full_jid, config
      else
        # Instant room
        result = @connection.muc.create full_jid
      end
      
    end
    
    def [](jid_node_num)
      case jid_node_num
      when Fixnum
        list[jid_node_num]
      when Jubjub::Jid
        list.find{|m| m.jid == jid_node_num }
      else
        j = Jubjub::Jid.new jid_node_num, jid.domain
        list.find{|m| m.jid == j }        
      end
    end
    
    # Hint that methods are actually applied to list using method_missing
    def inspect
      list.inspect
    end
    
  private
  
    def method_missing(name, *args, &block)
      list.send(name, *args, &block)
    end
      
    def list
      @list ||= @connection.muc.list @jid
    end
    
  end
  
  class MucConfiguration < DataForm
    
  end
  
end