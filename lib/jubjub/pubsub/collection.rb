# Uses proxy pattern for syntax sugar
# and delaying expensive operations until
# required
class Jubjub::Pubsub::Collection

  attr_reader :jid

  include Jubjub::Helpers::Collection

  def initialize(jid, connection)
    @jid = Jubjub::Jid.new jid
    @connection = connection
  end

  def create(node)
    @connection.pubsub.create jid, node
  end

  def create(node, config = nil, &block)
    if block_given?
      # Configure node
      config = @connection.pubsub.default_configuration jid
      yield config
    end
    @connection.pubsub.create jid, node, config
  end

  def destroy(node, redirect_jid = nil, redirect_node = nil)
    redirect_jid = Jubjub::Jid.new(redirect_jid) if redirect_jid
    @connection.pubsub.destroy jid, node, redirect_jid, redirect_node
  end

  def purge(node)
    @connection.pubsub.purge jid, node
  end

  def subscribe(node)
    @connection.pubsub.subscribe jid, node
  end

  def unsubscribe(node, subid=nil)
    @connection.pubsub.unsubscribe jid, node, subid
  end

  def [](node_num)
    case node_num
    when Fixnum
      list[node_num]
    else
      search_list(Jubjub::Pubsub.new( jid, node_num, @connection )){|p| p.node == node_num }
    end
  end

private

  def list
    @list ||= @connection.pubsub.list jid
  end

end
