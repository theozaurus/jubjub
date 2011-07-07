class Jubjub::Muc::AffiliationCollection
  
  attr_reader :jid
  
  def initialize(jid,connection)
    @jid = Jubjub::Jid.new jid
    @connection = connection
  end

  def [](jid_num)
    case jid_num
    when Fixnum
      affiliations[jid_num]
    when Jubjub::Jid
      affiliations.find{|i| i.jid == jid_num } || Jubjub::Muc::Affiliation.new( jid, jid_num, nil, nil, 'none', @connection )
    else
      j = Jubjub::Jid.new( jid_num )
      affiliations.find{|i| i.jid == j } || Jubjub::Muc::Affiliation.new( jid, j, nil, nil, 'none', @connection )
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
    # OPTIMIZE: These requests should be made in parallel, not sequentially
    @affiliations ||= %w(owner outcast member admin).map{|a| @connection.muc.retrieve_affiliations( jid, a ) }.flatten
  end
  
end