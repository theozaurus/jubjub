module Jubjub
  module Connection
    class XmppGateway
      module Helper

        def initialize(connection)
          @connection = connection
        end

        def write(stanza)
          @connection.write stanza.to_xml(:indent => 0, :save_with => Nokogiri::XML::Node::SaveOptions::NO_DECLARATION)
        end

      end
    end
  end
end
