module Jubjub
  class Response
    class Proxy

      # Turn proxy class into a 'BasicObject'
      instance_methods.each do |m|
        undef_method(m) if m.to_s !~ /(?:^__|^nil?$|^send$|^object_id$|^should$)/
      end
      
      attr_reader :proxy_primary, :proxy_secondary
      
      def initialize(primary, secondary, primary_method)
        @proxy_primary = primary
        @proxy_secondary = secondary
        @primary_method = primary_method
      end
      
      # We really want to show the secondary object
      # as the primary is just a thin layer on top
      def inspect
        proxy_secondary.inspect
      end
      
      # Used to give away this is really a proxy
      def proxy_class
        Jubjub::Response::Proxy
      end
      
    private

      def method_missing(name, *args, &block)
        # If the method exists on the primary use that
        # unless it's the method name called to create the proxy from the primary, or is a standard object method
        if name.to_s != @primary_method && (proxy_primary.public_methods - Object.public_methods).map{|m| m.to_s }.include?( name.to_s )
          proxy_primary.send(name, *args, &block)
        else
        # Else use a method on the secondary
          proxy_secondary.send(name, *args, &block)
        end
      end
      
    end
  end
end