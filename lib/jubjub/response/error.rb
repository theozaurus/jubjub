module Jubjub
  class Response
    class Error

      attr_reader :stanza

      def initialize(xml)
        @stanza = xml
      end

      def condition
        @condition ||= begin
          condition = @stanza.xpath('//error/ietf:*','ietf' => 'urn:ietf:params:xml:ns:xmpp-stanzas').first
          condition.name if condition
        end
      end

      def type
        @error_type ||= stanza.xpath('//error').first.attr('type')
      end

      def text(language=nil)
        if language
          xpath = "//error/text[@xml:lang='#{language}']"
        else
          xpath = "//error/text"
        end
        stanza.xpath(xpath).text
      end

    end
  end
end
