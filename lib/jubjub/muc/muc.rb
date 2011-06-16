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
    
    def ==(other)
      other.is_a?( self.class ) &&
      other.jid     == self.jid &&
      other.name    == self.name
    end
    
  end 

end