module Jubjub
  class Muc
    
    attr_reader :jid, :name
    
    def initialize(jid, name = nil, connection = nil)
      @jid = Jubjub::Jid.new(jid)
      @name = name
      @connection = connection
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
    
    def create(node, nick = nil)
      full_jid = Jubjub::Jid.new node, @jid.domain, nick || @connection.jid.node
      @connection.muc.create full_jid
    end
    
    # Hint that methods are actually applied to list using method_missing
    def inspect
      list.inspect
    end
    
  protected
  
    def method_missing(name, *args, &block)
      list.send(name, *args, &block)
    end
    
  private
  
    def list
      @list ||= @connection.muc.list @jid
    end
    
  end
  
  
end