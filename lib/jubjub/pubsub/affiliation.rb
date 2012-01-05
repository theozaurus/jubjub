class Jubjub::Pubsub::Affiliation

  attr_reader :pubsub_jid, :pubsub_node, :jid, :affiliation

  def initialize(pubsub_jid, pubsub_node, jid, affiliation, connection)
    @pubsub_jid = Jubjub::Jid.new pubsub_jid
    @pubsub_node = pubsub_node
    @jid = Jubjub::Jid.new jid
    @affiliation = affiliation
    @connection = connection
  end

  # Hide the connection details and show jid as string for compactness
  def inspect
    obj_id = "%x" % (object_id << 1)
    "#<#{self.class}:0x#{obj_id} @pubsub_jid=\"#{pubsub_jid}\" @pubsub_node=#{@pubsub_node} @jid=\"#{jid}\" @affiliation=#{affiliation.inspect}>"
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

  def set(new_affiliation)
    old_affiliation = @affiliation
    @affiliation = new_affiliation
    r = @connection.pubsub.modify_affiliations pubsub_jid, pubsub_node, self
    @affiliation = old_affiliation unless r
    r
  end

  def set_owner
    set 'owner'
  end

  def set_publisher
    set 'publisher'
  end

  def set_publish_only
    set 'publish-only'
  end

  def set_member
    set 'member'
  end

  def set_none
    set 'none'
  end

  def set_outcast
    set 'outcast'
  end

  def ==(other)
    other.is_a?( self.class ) &&
    other.pubsub_jid  == self.pubsub_jid &&
    other.pubsub_node == self.pubsub_node &&
    other.jid         == self.jid &&
    other.affiliation == self.affiliation
  end

end
