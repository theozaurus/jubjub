module Jubjub
  
  class Response
    
    attr_reader :stanza, :result
    
    def initialize(xml,&block)
      @stanza = xml
      
      @result = nil
      @result = yield stanza if block_given?
    end
    
    def proxy_result
      # Allows some syntax sugar. We can chain from the result, 
      # but still get access to the response via the proxy
      @proxy_result ||= Proxy.new self, result, 'proxy_result'
    end
    
    def success?
      @success ||= stanza.xpath('/iq[@type="result"]|/iq[@type="set"]|/iq[@type="get"]').any?
    end
    
    def error
      @errors ||= begin
        s = stanza.at_xpath('/iq[@type="error"]/error')
        Error.new s if s
      end
    end
    
  end
  
end
