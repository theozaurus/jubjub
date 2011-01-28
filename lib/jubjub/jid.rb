module Jubjub
  class Jid
    
    PATTERN = /^(?:([^@]*)@)??([^@\/]*)(?:\/(.*?))?$/
    
    attr_reader :node, :domain, :resource
    
    def initialize(node, domain = nil, resource = nil)
      if node.is_a? Jid
        @node = node.node
        @domain = node.domain
        @resource = node.resource
      else
        @node = node
        @domain = domain
        @resource = resource
      end
      
      if @domain.nil? && @resource.nil?
        @node, @domain, @resource = node.to_s.scan(PATTERN).first
      end
    end
    
    def to_s
      (node ? "#{node}@" : '') + domain + (resource ? "/#{resource}" : '')
    end
    
    def ==(obj)
      obj.is_a?( self.class ) && obj.to_s == self.to_s
    end
    
  end
end