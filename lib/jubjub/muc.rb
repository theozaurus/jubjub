module Jubjub
  class Muc
    
    attr_reader :jid, :name
    
    def initialize(jid, name = nil, connection = nil)
      @jid = Jubjub::Jid.new(jid)
      @name = name
      @connection = connection
    end 
    
    def exit(nick = nil)
      full_jid = Jubjub::Jid.new @jid.node, @jid.domain, nick || @connection.jid.node
      
      @connection.muc.exit(full_jid)
      self
    end
    
    def destroy
      @connection.muc.destroy(@jid)
    end
    
    # Hide the connection details and show jid as string for compactness
    def inspect
      obj_id = "%x" % (object_id << 1)
      "#<#{self.class}:0x#{obj_id} @jid=\"#{@jid}\" @name=#{@name.inspect}>"
    end
    
  end
  
  # Uses proxy pattern for syntax sugar
  # and delaying expensive operations until
  # required
  class MucCollection
     
    attr_reader :jid
     
    def initialize(jid, connection)
      @jid = Jubjub::Jid.new(jid)
      @connection = connection
    end
    
    def create(node, nick = nil, &block)
      full_jid = Jubjub::Jid.new node, @jid.domain, nick || @connection.jid.node

      if block_given?
        # Reserved room
        config = @connection.muc.configuration full_jid
        yield config
        @connection.muc.create full_jid, config
      else
        # Instant room
        result = @connection.muc.create full_jid
      end
      
    end
    
    # Hint that methods are actually applied to list using method_missing
    def inspect
      list.inspect
    end
    
  private
  
    def method_missing(name, *args, &block)
      list.send(name, *args, &block)
    end
      
    def list
      @list ||= @connection.muc.list @jid
    end
    
  end
  
  class MucConfiguration
    
    attr_reader :fields
    
    def initialize(config)
      check_config config
      
      @fields = config
    end
    
    def [](arg)
      if fields.has_key? arg
        case fields[arg][:type]
        when 'boolean'
          fields[arg][:value] == '1' || fields[arg][:value] == 'true' || fields[arg][:value] == true ? true : false
        when 'jid-multi'
          fields[arg][:value].map{|j| Jubjub::Jid.new j }
        when 'jid-single'
          Jubjub::Jid.new fields[arg][:value]
        else
          fields[arg][:value]
        end
      end
    end
    
    def []=(arg,value)
      if fields.has_key? arg
        check_options arg, value if fields[arg].has_key?(:options)
        value = Array[value].flatten if fields[arg][:type].match /-multi$/
        fields[arg][:value] = value
      else
        raise Jubjub::ArgumentError.new("#{arg} is not a valid field")
      end
    end
    
    def settings
      Hash[fields.keys.map{|field|
        [field, Array[self[field]].flatten]
      }]
    end
    
    def ==(thing)
      thing.is_a?( self.class ) && thing.fields == self.fields
    end
    
  private
  
    def check_options(name, value)
      valid_options = fields[name][:options].map{|o| o[:value].to_s }
      invalid_options = Array[value].flatten - valid_options
      raise Jubjub::ArgumentError.new(
        "#{invalid_options.join(', ')} is not an accepted value please choose from #{valid_options.join(', ')}"
      ) if invalid_options.any?
    end
  
    def check_config(config)
      required = [:type]
      understood = required + [:label, :options, :value]    
      
      raise Jubjub::ArgumentError.new("please initialize with a hash of the format { 'foo' => {:type => 'boolean', :value => false, :label => 'Fooey'} }") unless config.is_a? Hash
      
      config.each do |name,argument|
        required.each{|r| raise Jubjub::ArgumentError.new(":#{r} is missing for #{name}") unless argument.keys.include? r }
        
        mystery_arguments = (argument.keys - understood)
        raise Jubjub::ArgumentError.new(
          ":#{mystery_arguments.join(', :')} is not a recognised option for #{name}"
        ) if mystery_arguments.any?
      end
    end
    
  end
  
end