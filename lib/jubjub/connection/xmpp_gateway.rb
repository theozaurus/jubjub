require "net/http"
require "nokogiri"
require "jubjub/connection/xmpp_gateway/muc"
require "jubjub/connection/xmpp_gateway/pubsub"

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

      def pubsub
        @pubsub ||= Pubsub.new(self)
      end

      def write(stanza)
        req = Net::HTTP::Post.new( url.path )
        req.basic_auth( @jid.to_s, @password )
        req.set_form_data( { 'stanza'=> stanza }, ';' )
        res = Net::HTTP.new(url.host, url.port).start {|http| http.request req }
        case res
        when Net::HTTPSuccess
          # OK
        else
          #res.error!
        end
        decode res.body
      end

    private

      def url
        URI.parse "http://#{@settings[:host]}:#{@settings[:port]}/"
      end

      def decode(http_body)
        Nokogiri::XML::Document.parse http_body
      end

    end
  end
end
