class Jubjub::Pubsub

  attr_reader :jid, :node

  def initialize(jid, node, connection)
    @jid = Jubjub::Jid.new jid
    @node = node
    @connection = connection
  end

  def destroy(redirect_jid = nil, redirect_node = nil)
    redirect_jid = Jubjub::Jid.new(redirect_jid) if redirect_jid
    @connection.pubsub.destroy jid, node, redirect_jid, redirect_node
  end

  def purge
    @connection.pubsub.purge jid, node
  end

  def subscribe
    @connection.pubsub.subscribe jid, node
  end

  def unsubscribe(subid = nil)
    @connection.pubsub.unsubscribe jid, node, subid
  end

  def publish(data, item_id = nil)
    @connection.pubsub.publish jid, node, data, item_id
  end

  def retract(item_id)
    @connection.pubsub.retract jid, node, item_id
  end

  # Hide the connection details and show jid as string for compactness
  def inspect
    obj_id = "%x" % (object_id << 1)
    "#<#{self.class}:0x#{obj_id} @jid=\"#{jid}\" @node=#{node.inspect}>"
  end

  def items
    ItemCollection.new jid, node, @connection
  end

  def subscriptions
    SubscriptionCollection.new jid, node, @connection
  end

  def affiliations
    AffiliationCollection.new jid, node, @connection
  end

  def uri
    "xmpp:#{@jid}?;node=#{@node}"
  end

  def ==(other)
    other.is_a?( self.class ) &&
    other.jid     == self.jid &&
    other.node    == self.node
  end

private

  def method_missing(name, *args, &block)
    items.send(name, *args, &block)
  end

end
