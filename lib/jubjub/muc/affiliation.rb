class Jubjub::Muc::Affiliation

  attr_reader :muc_jid, :jid, :nick, :role, :affiliation

  def initialize(muc_jid, jid, nick, role, affiliation, connection)
    @muc_jid = Jubjub::Jid.new muc_jid
    @jid = Jubjub::Jid.new jid
    @nick = nick
    @role = role
    @affiliation = affiliation
    @connection = connection
  end

  # Hide the connection details and show jid as string for compactness
  def inspect
    obj_id = "%x" % (object_id << 1)
    "#<#{self.class}:0x#{obj_id} @muc_jid=\"#{muc_jid}\" @jid=\"#{jid}\" @nick=#{@nick.inspect} @affiliation=#{affiliation.inspect}  @role=#{@role.inspect}>"
  end

  def outcast?
    affiliation == "outcast"
  end

  def none?
    affiliation == "none"
  end

  def member?
    affiliation == "member"
  end

  def admin?
    affiliation == "admin"
  end

  def owner?
    affiliation == "owner"
  end

  def set(new_affiliation)
    old_affiliation = @affiliation
    @affiliation = new_affiliation
    r = @connection.muc.modify_affiliations muc_jid, self
    @affiliation = old_affiliation unless r
    r
  end

  def set_outcast
    set 'outcast'
  end

  def set_none
    set 'none'
  end

  def set_member
    set 'member'
  end

  def set_admin
    set 'admin'
  end

  def set_owner
    set 'owner'
  end

  def ==(other)
    other.is_a?( self.class ) &&
    other.muc_jid     == self.muc_jid &&
    other.jid         == self.jid &&
    other.nick        == self.nick &&
    other.role        == self.role &&
    other.affiliation == self.affiliation
  end

end
