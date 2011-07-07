module Jubjub
  module Helpers
    module Collection
      
      # Hint that methods are actually applied to list using method_missing
      def inspect
        list.inspect
      end
    
      def search_list(default=nil, &block)
        list.find( &block ) || default
      end
      private :search_list

      def method_missing(name, *args, &block)
        list.send(name, *args, &block)
      end
      private :method_missing
      
    end
  end
end