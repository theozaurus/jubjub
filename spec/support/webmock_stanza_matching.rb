require "equivalent-xml"
require "vcr/request_matcher"
require "vcr/http_stubbing_adapters/common"
require "vcr/http_stubbing_adapters/webmock"

module VCR
  module HttpStubbingAdapters
    module WebMock

      # Hack in stub to compare with :stanza
      def stub_requests(http_interactions, match_attributes)
        grouped_responses(http_interactions, match_attributes).each do |request_matcher, responses|
          stub = ::WebMock.stub_request(request_matcher.method || :any, request_matcher.uri)

          with_hash = request_signature_hash(request_matcher)
          stub = stub.with{|r|
            conditions = []
            conditions << (r.headers == with_hash[:headers]) if with_hash.has_key? :headers
            conditions << EquivalentXml.equivalent?(body_to_stanza(r.body), body_to_stanza(with_hash[:body]), {
              :element_order => true,
              :normalize_whitespace => true
            }) if with_hash.has_key? :body
            conditions.all?
          } if with_hash.size > 0

          stub.to_return(responses.map{ |r| response_hash(r) })
        end
      end

      # Code to deal with the stanza
      def body_to_stanza(body)
        if body
          # Split body at '&', then split each element at '=' creating the key and value. Unescape these and turn into hash.
          params = Hash[ body.split("&").map{|c| c.split('=').map{|v| URI.unescape(v) } } ]
          # Pull out stanza attribute and turn into Nokogiri XML document
          Nokogiri::XML params["stanza"]
        end
      end

    end
  end
end
