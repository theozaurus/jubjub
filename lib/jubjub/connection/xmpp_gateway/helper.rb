module Jubjub
  module Connection
    class XmppGateway
      module Helper
        
        def initialize(connection)
          @connection = connection
        end
        
        def write(stanza)
          @connection.write(stanza)
        end
        
      end
    end
  end
end