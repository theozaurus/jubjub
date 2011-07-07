class Jubjub::Muc::AffiliationCollection
  
  attr_reader :jid
  
  include Jubjub::Helpers::Collection
  
  def initialize(jid,connection)
    @jid = Jubjub::Jid.new jid
    @connection = connection
  end

  def [](jid_num)
    case jid_num
    when Fixnum
      list[jid_num]
    when Jubjub::Jid
      search_list( Jubjub::Muc::Affiliation.new( jid, jid_num, nil, nil, 'none', @connection ) ){|i| i.jid == jid_num }
    else
      j = Jubjub::Jid.new( jid_num )
      search_list( Jubjub::Muc::Affiliation.new( jid, j, nil, nil, 'none', @connection ) ){|i| i.jid == j }
    end
  end

private
  
  def list
    # OPTIMIZE: These requests should be made in parallel, not sequentially
    @list ||= %w(owner outcast member admin).map{|a| @connection.muc.retrieve_affiliations( jid, a ) }.flatten
  end
  
end