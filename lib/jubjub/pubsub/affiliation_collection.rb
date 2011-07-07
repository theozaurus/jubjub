class Jubjub::Pubsub::AffiliationCollection
  
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
      search_list( Jubjub::Pubsub::Affiliation.new( jid, node, jid_num, 'none', @connection ) ){|i| i.jid == jid_num }
    else
      j = Jubjub::Jid.new( jid_num )
      search_list( Jubjub::Pubsub::Affiliation.new( jid, node, j, 'none', @connection ) ){|i| i.jid == j }
    end
  end

private
  
  def list
    @list ||= @connection.pubsub.retrieve_affiliations( @jid, @node )
  end
  
end