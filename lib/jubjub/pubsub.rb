require "jubjub/connection/xmpp_gateway/pubsub"

module Jubjub
  
  class Pubsub
    
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
    
  end
  
  class PubsubItem
    
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
    
  end
  
  class PubsubSubscription
    
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
  
  # Uses proxy pattern for syntax sugar
  # and delaying expensive operations until
  # required
  class PubsubCollection
     
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
        list.find{|p| p.node == node_num }        
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
  
end