# Uses proxy pattern for syntax sugar
# and delaying expensive operations until
# required
class Jubjub::Pubsub::Collection
   
  attr_reader :jid
   
  def initialize(jid, connection)
    @jid = Jubjub::Jid.new jid
    @connection = connection
  end
  
  def create(node)
    @connection.pubsub.create jid, node
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
      list.find{|p| p.node == node_num } || Jubjub::Pubsub.new( jid, node_num, @connection )
    end
  end
  
  # Hint that methods are actually applied to list using method_missing
  def inspect
    list.inspect
  end

private

  def method_missing(name, *args, &block)
    list.send(name, *args, &block)
  end
  
  def list
    @list ||= @connection.pubsub.list jid
  end
  
end