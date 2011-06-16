class Jubjub::Pubsub::AffiliationCollection
  
  attr_reader :jid, :node
  
  def initialize(jid,node,connection)
    @jid = Jubjub::Jid.new jid
    @node = node
    @connection = connection
  end

  def [](jid_num)
    case jid_num
    when Fixnum
      affiliations[jid_num]
    when Jubjub::Jid
      affiliations.find{|i| i.jid == jid_num } || Jubjub::Pubsub::Affiliation.new( jid, node, jid_num, 'none', @connection )
    else
      j = Jubjub::Jid.new( jid_num )
      affiliations.find{|i| i.jid == j } || Jubjub::Pubsub::Affiliation.new( jid, node, j, 'none', @connection )
    end
  end

  # Hint that methods are actually applied to list using method_missing
  def inspect
    affiliations.inspect
  end

private

  def method_missing(name, *args, &block)
    affiliations.send(name, *args, &block)
  end
  
  def affiliations
    @affiliations ||= @connection.pubsub.retrieve_affiliations( @jid, @node )
  end
  
end