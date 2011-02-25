require 'jubjub/connection/xmpp_gateway/helper'
require 'jubjub/pubsub'

module Jubjub
  module Connection
    class XmppGateway
      class Pubsub
        
        include Helper
        
        def initialize(connection)
          @connection = connection
        end
        
        # http://xmpp.org/extensions/xep-0060.html#entity-nodes
        # <iq type='get'
        #     from='francisco@denmark.lit/barracks'
        #     to='pubsub.shakespeare.lit'
        #     id='nodes1'>
        #   <query xmlns='http://jabber.org/protocol/disco#items'/>
        # </iq>
        # 
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     to='francisco@denmark.lit/barracks'
        #     id='nodes1'>
        #   <query xmlns='http://jabber.org/protocol/disco#items'>
        #     <item jid='pubsub.shakespeare.lit'
        #           node='blogs'
        #           name='Weblog updates'/>
        #     <item jid='pubsub.shakespeare.lit'
        #           node='news'
        #           name='News and announcements'/>
        #   </query>
        # </iq>
        def list(jid)
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'get') {
              xml.query_('xmlns' => namespaces['disco_items'])
            }
          end
          
          write(
            # Generate stanza
            request.to_xml
          ).xpath(
            # Pull out required parts
            '//iq[@type="result"]/disco_items:query/disco_items:item',
            namespaces
          ).map{|item|
            jid  = item.attr('jid')
            node = item.attr('node')
            Jubjub::Pubsub.new jid, node, @connection
          }
        end
        
        # http://xmpp.org/extensions/xep-0060.html#owner-create
        # <iq type='set'
        #     from='hamlet@denmark.lit/elsinore'
        #     to='pubsub.shakespeare.lit'
        #     id='create1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        #     <create node='princely_musings'/>
        #   </pubsub>
        # </iq>
        # 
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     to='hamlet@denmark.lit/elsinore'
        #     id='create2'>
        #     <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        #       <create node='25e3d37dabbab9541f7523321421edc5bfeb2dae'/>
        #     </pubsub>
        # </iq>
        def create(jid, node)          
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'set') {
              xml.pubsub_('xmlns' => namespaces['pubsub']) {
                xml.create_('node' => node)
              }
            }
          end
          
          success = write(
            # Generate stanza
            request.to_xml
          ).xpath(
            # Pull out required parts
            '//iq[@type="result"]/pubsub:pubsub/pubsub:create',
            namespaces
          ).any?
          Jubjub::Pubsub.new jid, node, @connection if success
        end
        
        # http://xmpp.org/extensions/xep-0060.html#owner-delete
        # <iq type='set'
        #     from='hamlet@denmark.lit/elsinore'
        #     to='pubsub.shakespeare.lit'
        #     id='delete1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
        #     <delete node='princely_musings'>
        #       <redirect uri='xmpp:hamlet@denmark.lit?;node=blog'/>
        #     </delete>
        #   </pubsub>
        # </iq>
        # 
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     id='delete1'/>
        def destroy(jid, node, redirect_jid = nil, redirect_node = nil)        
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'set') {
              xml.pubsub_('xmlns' => namespaces['pubsub_owner']) {
                xml.delete_('node' => node){
                  xml.redirect( 'uri' => pubsub_uri(redirect_jid, redirect_node) ) if redirect_jid && redirect_node
                }
              }
            }
          end
          
          success = write(
            # Generate stanza
            request.to_xml
          ).xpath(
            # Pull out required parts
            '//iq[@type="result"]'
          ).any?
        end
        
        # http://xmpp.org/extensions/xep-0060.html#subscriber-subscribe
        # <iq type='set'
        #     from='francisco@denmark.lit/barracks'
        #     to='pubsub.shakespeare.lit'
        #     id='sub1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        #     <subscribe
        #         node='princely_musings'
        #         jid='francisco@denmark.lit'/>
        #   </pubsub>
        # </iq>
        #
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     to='francisco@denmark.lit/barracks'
        #     id='sub1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        #     <subscription
        #         node='princely_musings'
        #         jid='francisco@denmark.lit'
        #         subid='ba49252aaa4f5d320c24d3766f0bdcade78c78d3'
        #         subscription='subscribed'/>
        #   </pubsub>
        # </iq>
        def subscribe(jid, node)        
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'set') {
              xml.pubsub_('xmlns' => namespaces['pubsub']) {
                xml.subscribe_('node' => node, 'jid' => subscriber)
              }
            }
          end
          
          result = write(
            # Generate stanza
            request.to_xml
          ).xpath(
            # Pull out required parts
            '//iq[@type="result"]/pubsub:pubsub/pubsub:subscription',
            namespaces
          )
          if result.any?
            subscriber   = Jubjub::Jid.new(result.first.attr('jid'))
            subid        = result.first.attr('subid') 
            subscription = result.first.attr('subscription')
            Jubjub::PubsubSubscription.new jid, node, subscriber, subid, subscription, @connection
          end
        end
        
        # http://xmpp.org/extensions/xep-0060.html#subscriber-unsubscribe
        # <iq type='set'
        #     from='francisco@denmark.lit/barracks'
        #     to='pubsub.shakespeare.lit'
        #     id='unsub1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        #      <unsubscribe
        #          node='princely_musings'
        #          jid='francisco@denmark.lit'/>
        #   </pubsub>
        # </iq>
        # 
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     to='francisco@denmark.lit/barracks'
        #     id='unsub1'/>
        def unsubscribe(jid, node, subid=nil)        
          unsubscribe_options = {'node' => node, 'jid' => subscriber}
          unsubscribe_options['subid'] = subid if subid
          
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'set') {
              xml.pubsub_('xmlns' => namespaces['pubsub']) {
                xml.unsubscribe_(unsubscribe_options)
              }
            }
          end
          
          write(
            # Generate stanza
            request.to_xml
          ).xpath(
            # Pull out required parts
            '//iq[@type="result"]'
          ).any?
        end
      
      private
      
        def subscriber
          Jubjub::Jid.new @connection.jid.node, @connection.jid.domain
        end
        
        def pubsub_uri(jid, node)
          "xmpp:#{jid}?;node=#{node}"
        end
      
        def namespaces
          {
            'disco_items'  => 'http://jabber.org/protocol/disco#items',
            'pubsub'       => 'http://jabber.org/protocol/pubsub',
            'pubsub_owner' => 'http://jabber.org/protocol/pubsub#owner'
          }
        end
        
      end
    end
  end
end