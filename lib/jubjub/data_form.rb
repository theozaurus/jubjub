require "nokogiri"

module Jubjub
  class DataForm

    attr_reader :fields

    def initialize(config={})
      if config.respond_to? :xpath
        config = convert_xml config
      else
        config = clean_config config if config.is_a? Hash
      end

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

    def to_builder(root_doc=Nokogiri::XML.parse(""))
      Nokogiri::XML::Builder.with(root_doc) do |xml|
        xml.x_('xmlns' => 'jabber:x:data', :type => 'submit') {
          fields.each{|name,settings|
            options = {'var' => name}
            options[:type] = settings[:type] if settings[:type]
            values = Array[self[name]].flatten
            xml.field_(options){
              values.each {|v|
                xml.value_ v
              }
            }
          }
        }
      end
    end

  private

    def check_options(name, value)
      valid_options = fields[name][:options].map{|o| o[:value].to_s }
      invalid_options = Array[value].flatten - valid_options
      raise Jubjub::ArgumentError.new(
        "#{invalid_options.join(', ')} is not an accepted value please choose from #{valid_options.join(', ')}"
      ) if invalid_options.any?
    end

    def clean_config(config)
      # Symbolize the keys
      Hash[config.map{|name, arguments| [name, recursive_symbolize_keys(arguments)] }]
    end

    def check_config(config)
      required = []
      understood = required + [:type, :label, :options, :value]

      raise Jubjub::ArgumentError.new("please initialize with a hash of the format { 'foo' => {:type => 'boolean', :value => false, :label => 'Fooey'} }") unless config.is_a? Hash

      config.each do |name,argument|
        required.each{|r| raise Jubjub::ArgumentError.new(":#{r} is missing for #{name}") unless argument.keys.include? r }

        mystery_arguments = (argument.keys - understood)
        raise Jubjub::ArgumentError.new(
          ":#{mystery_arguments.join(', :')} is not a recognised option for #{name}"
        ) if mystery_arguments.any?
      end
    end

    def convert_xml(config)
      config.xpath(
        # Get fields
        "//x_data:x[@type='form']/x_data:field",
        namespaces
      ).inject({}){|result,field|
        # Build parameters
        hash = {}
        hash[:type]  = field.attr 'type'
        hash[:label] = field.attr 'label'

        value = field.xpath('x_data:value', namespaces)
        hash[:value] = hash[:type].match(/\-multi$/) ? value.map{|e| e.content } : value.text

        options = field.xpath('x_data:option', namespaces).map{|o|
          { :label => o.attr('label'), :value => o.xpath('x_data:value', namespaces).text }
        }
        hash[:options] = options if options.any?

        result[field.attr 'var'] = hash unless hash[:type] == 'fixed'
        result
      }
    end

    def namespaces
      { 'x_data' => 'jabber:x:data' }
    end

    def recursive_symbolize_keys(hash)
      new_hash = symbolize_keys hash
      new_hash.each{|k,v|
        r = case v
        when Array
          v.map{|vv| vv.is_a?( Hash ) ? recursive_symbolize_keys(vv) : vv }
        when Hash
          recursive_symbolize_keys v
        else
          v
        end
        new_hash[k] = r
      }

      new_hash
    end

    def symbolize_keys(hash)
      new_hash = {}
      hash.keys.each do |key|
        new_hash[(key.to_sym rescue key) || key] = hash[key]
      end
      new_hash
    end

  end

end
