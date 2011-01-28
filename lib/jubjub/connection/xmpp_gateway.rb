require "curb"
require "nokogiri"
require "jubjub/connection/xmpp_gateway/muc"

module Jubjub
  module Connection
    class XmppGateway
      
      attr_reader :jid
      
      def initialize(jid,password,settings)
        @jid      = jid
        @password = password
        @settings = settings
      end
      
      def muc
        @muc ||= Muc.new(self)
      end
      
      def write(stanza)
        decode(Curl::Easy.perform(url){|e|
          e.username = @jid.to_s
          e.password = @password
          e.post_body = Curl::PostField.content('stanza',stanza).to_s
          e.http_auth_types = :basic
        })
      end

    private
    
      def url
        "http://#{@settings[:host]}:#{@settings[:port]}"
      end
      
      def decode(curl_response)
        Nokogiri::XML::Document.parse curl_response.body_str
      end

    end
  end
end