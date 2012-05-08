class Jubjub::Pubsub::SubscriptionCollection

  attr_reader :jid, :node

  include Jubjub::Helpers::Collection

  def initialize(jid,node,connection)
    @jid = Jubjub::Jid.new jid
    @node = node
    @connection = connection
  end

  def [](jid_num)
    case jid_num
    when Fixnum
      list[jid_num]
    when Jubjub::Jid
      search_list( Jubjub::Pubsub::Subscription.new( jid, node, jid_num, nil, 'unsubscribed', @connection ) ){|i| i.subscriber == jid_num }
    else
      j = Jubjub::Jid.new( jid_num )
      search_list( Jubjub::Pubsub::Subscription.new( jid, node, j, nil, 'unsubscribed', @connection ) ){|i| i.subscriber == j }
    end
  end

private

  def list
    @list ||= @connection.pubsub.subscriptions( @jid, @node )
  end

end
