class Jubjub::Pubsub::Affiliation
  
  attr_reader :jid, :affiliation
  
  def initialize(jid,affiliation,connection)
    @jid = Jubjub::Jid.new jid
    @affiliation = affiliation
    @connection = connection
  end

  # Hide the connection details and show jid as string for compactness
  def inspect
    obj_id = "%x" % (object_id << 1)
    "#<#{self.class}:0x#{obj_id} @jid=\"#{jid}\" @affiliation=#{affiliation.inspect}>"
  end
  
  def owner?
    affiliation == "owner"
  end
  
  def publisher?
    affiliation == "publisher"
  end
  
  def publish_only?
    affiliation == "publish-only"
  end
  
  def member?
    affiliation == "member"
  end
  
  def none?
    affiliation == "none"
  end
  
  def outcast?
    affiliation == "outcast"
  end
  
  def ==(other)
    other.is_a?( self.class ) &&
    other.jid         == self.jid &&
    other.affiliation == self.affiliation
  end
  
end