class Jubjub::Pubsub::Item
  
  attr_reader :jid, :node, :item_id, :data
  
  def initialize(jid, node, item_id, data, connection)
    @jid = Jubjub::Jid.new jid
    @node = node
    @item_id = item_id
    @data = data
    @connection = connection
  end
  
  # Hide the connection details and show jid as string for compactness
  def inspect
    obj_id = "%x" % (object_id << 1)
    "#<#{self.class}:0x#{obj_id} @jid=\"#{jid}\" @node=#{node.inspect} @item_id=#{item_id.inspect} @data=#{data.inspect}>"
  end
  
  def retract
    @connection.pubsub.retract jid, node, item_id
  end
  
  def ==(other)
    other.is_a?( self.class ) &&
    other.jid     == self.jid &&
    other.node    == self.node &&
    other.item_id == self.item_id &&
    other.data    == self.data
  end
  
  def uri
    "xmpp:#{@jid}?;node=#{@node};item=#{@item_id}"
  end
  
end