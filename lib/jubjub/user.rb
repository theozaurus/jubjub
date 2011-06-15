require 'jubjub/errors'
require 'jubjub/jid'
require 'jubjub/connection/xmpp_gateway'
require 'jubjub/pubsub'
require 'jubjub/muc'
require 'jubjub/data_form'

module Jubjub
  
  module User
        
    def self.included base
      base.extend ClassMethods
    end
    
    module ClassMethods
      def jubjub_client options = {}
        # Setup defaults
        default_connection_settings = {
          :host => '127.0.0.1',
          :port => '8000'
        }.merge options[:connection_settings] || {}
        
        [:jid, :password].each do |key|
          raise Jubjub::ArgumentError.new("missing :#{key} option") unless options.has_key? key
        end
        
        define_method "jubjub_jid" do
          Jubjub::Jid.new(send(options[:jid]))
        end
        
        define_method "jubjub_password" do
          send(options[:password])
        end
        
        define_method "jubjub_connection_settings" do
          default_connection_settings
        end
        
        include InstanceMethods
      end
    end
    
    module InstanceMethods
      def jubjub_connection
        @jubjub_connection ||= Jubjub::Connection::XmppGateway.new(jubjub_jid, jubjub_password, jubjub_connection_settings)
      end
      
      def authenticated?
        jubjub_connection.authenticated?
      end
      
      # List muc rooms
      # if no jid is specified will default to 'connection.JID_DOMAIN'
      def mucs(jid = nil)
        jid ||= "conference.#{jubjub_jid.domain}"
        Jubjub::MucCollection.new jid, jubjub_connection
      end
      
      def pubsub(jid = nil)
        jid ||= "pubsub.#{jubjub_jid.domain}"
        Jubjub::Pubsub::Collection.new jid, jubjub_connection
      end
    end
    
  end
  
end