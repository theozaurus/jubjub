class Jubjub::Pubsub::Subscription

  attr_reader :jid, :node, :subscriber, :subid, :subscription

  def initialize(jid, node, subscriber, subid, subscription, connection)
    @jid          = Jubjub::Jid.new jid
    @node         = node
    @subscriber   = Jubjub::Jid.new subscriber
    @subid        = subid
    @subscription = subscription
    @connection   = connection
  end

  def unsubscribe
    @connection.pubsub.unsubscribe jid, node, subid
  end

  # Hide the connection details and show jid as string for compactness
  def inspect
    obj_id = "%x" % (object_id << 1)
    "#<#{self.class}:0x#{obj_id} @jid=\"#{jid}\" @node=#{node.inspect} @subscriber=\"#{subscriber}\" @subid=#{subid.inspect} @subscription=#{subscription.inspect}>"
  end

end
