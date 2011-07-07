# Uses proxy pattern for syntax sugar
# and delaying expensive operations until
# required
class Jubjub::Muc::Collection
   
  attr_reader :jid
  
  include Jubjub::Helpers::Collection
  
  def initialize(jid, connection)
    @jid = Jubjub::Jid.new(jid)
    @connection = connection
  end
  
  def create(node, nick = nil, &block)
    full_jid = Jubjub::Jid.new node, @jid.domain, nick || @connection.jid.node

    if block_given?
      # Reserved room
      config = @connection.muc.configuration full_jid
      yield config
      @connection.muc.create full_jid, config
    else
      # Instant room
      result = @connection.muc.create full_jid
    end
    
  end
  
  def [](jid_node_num)
    case jid_node_num
    when Fixnum
      list[jid_node_num]
    when Jubjub::Jid
      search_list( Jubjub::Muc.new( jid_node_num, nil, @connection ) ){|m| m.jid == jid_node_num }
    else
      j = Jubjub::Jid.new jid_node_num, jid.domain
      search_list( Jubjub::Muc.new( j, nil, @connection ) ){|m| m.jid == j }
    end
  end
  
private
  
  def list
    @list ||= @connection.muc.list @jid
  end
  
end