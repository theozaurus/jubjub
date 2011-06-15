def xml_fixture(location)
  Nokogiri::XML::Document.parse(File.open(fixture_path(location + ".xml")))
end

def fixture_path(location)
  File.join(File.dirname(File.dirname(__FILE__)),'fixtures',location)
end