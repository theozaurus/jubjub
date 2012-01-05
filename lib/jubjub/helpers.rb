module Jubjub
  module Helpers
    module Collection

      # Hint that methods are actually applied to list using method_missing
      def inspect
        list.inspect
      end

      def search_list(default=nil, &block)
        list unless default # We HAVE to search unless there is a default
        if list?
          list.find( &block ) || default
        else
          default
        end
      end
      private :search_list

      def method_missing(name, *args, &block)
        list.send(name, *args, &block)
      end
      private :method_missing

      def list?
        instance_variable_defined?("@list")
      end
      private :list?

    end
  end
end
