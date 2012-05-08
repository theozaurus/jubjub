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

  def subscribe
    if @connection.jid != subscriber
      @connection.pubsub.set_subscriptions( jid, node, { subscriber.to_s => "subscribed" } )
    else
      @connection.pubsub.subscribe jid, node
    end
  end

  def unsubscribe
    if @connection.jid != subscriber
      @connection.pubsub.set_subscriptions( jid, node, { subscriber.to_s => "none" } )
    else
      @connection.pubsub.unsubscribe jid, node, subid
    end
  end

  # Hide the connection details and show jid as string for compactness
  def inspect
    obj_id = "%x" % (object_id << 1)
    "#<#{self.class}:0x#{obj_id} @jid=\"#{jid}\" @node=#{node.inspect} @subscriber=\"#{subscriber}\" @subid=#{subid.inspect} @subscription=#{subscription.inspect}>"
  end

  def ==(other)
    other.is_a?( self.class ) &&
    other.jid          == self.jid &&
    other.node         == self.node &&
    other.subscriber   == self.subscriber &&
    other.subid        == self.subid &&
    other.subscription == self.subscription
  end

end
