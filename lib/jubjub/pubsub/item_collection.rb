class Jubjub::Pubsub::ItemCollection
  
  attr_reader :jid, :node
  
  def initialize(jid,node,connection)
    @jid = Jubjub::Jid.new jid
    @node = node
    @connection = connection
  end

  def [](item_num)
    case item_num
    when Fixnum
      items[item_num]
    else
      items.find{|i| i.item_id == item_num }        
    end
  end

  # Hint that methods are actually applied to list using method_missing
  def inspect
    items.inspect
  end

private

  def method_missing(name, *args, &block)
    items.send(name, *args, &block)
  end
  
  def items
    @items ||= @connection.pubsub.retrieve_items( @jid, @node )
  end
  
end