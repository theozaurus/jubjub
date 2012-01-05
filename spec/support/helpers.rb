def xml_fixture(location)
  Nokogiri::XML::Document.parse(File.open(fixture_path(location + ".xml")))
end

def fixture_path(location)
  File.join(File.dirname(File.dirname(__FILE__)),'fixtures',location)
end

def muc_affiliation_factory(override = {})
  options = {
    :muc_jid     => Jubjub::Jid.new("borogove@conference.foo.com"),
    :jid         => "mimsy@foo.com",
    :nick        => 'mimsy',
    :role        => 'none',
    :affiliation => 'none',
    :connection  => 'SHHHH CONNECTION OBJECT'
  }.merge( override )

  Jubjub::Muc::Affiliation.new(
    options[:muc_jid],
    options[:jid],
    options[:nick],
    options[:role],
    options[:affiliation],
    options[:connection]
  )
end
