class Jubjub::Pubsub::ItemCollection

  attr_reader :jid, :node

  include Jubjub::Helpers::Collection

  def initialize(jid,node,connection)
    @jid = Jubjub::Jid.new jid
    @node = node
    @connection = connection
  end

  def [](item_num)
    case item_num
    when Fixnum
      list[item_num]
    else
      search_list{|i| i.item_id == item_num }
    end
  end

private

  def list
    @list ||= @connection.pubsub.retrieve_items( @jid, @node )
  end

end
