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
        
        # http://xmpp.org/extensions/xep-0060.html#owner-purge
        # <iq type='set'
        #     from='hamlet@denmark.lit/elsinore'
        #     to='pubsub.shakespeare.lit'
        #     id='purge1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
        #     <purge node='princely_musings'/>
        #   </pubsub>
        # </iq>
        #
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     id='purge1'/>
        def purge(jid,node)
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'set') {
              xml.pubsub_('xmlns' => namespaces['pubsub_owner']) {
                xml.purge_('node' => node)
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
            Jubjub::Pubsub::Subscription.new jid, node, subscriber, subid, subscription, @connection
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
        
        # http://xmpp.org/extensions/xep-0060.html#publisher-publish
        # <iq type='set'
        #     from='hamlet@denmark.lit/blogbot'
        #     to='pubsub.shakespeare.lit'
        #     id='publish1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        #     <publish node='princely_musings'>
        #       <item id='ae890ac52d0df67ed7cfdf51b644e901'>
        #         ...
        #       </item>
        #     </publish>
        #   </pubsub>
        # </iq>
        # 
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     to='hamlet@denmark.lit/blogbot'
        #     id='publish1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        #     <publish node='princely_musings'>
        #       <item id='ae890ac52d0df67ed7cfdf51b644e901'/>
        #     </publish>
        #   </pubsub>
        # </iq>
        def publish(jid, node, data, item_id = nil)
          item_options = {}
          item_options[:id] = item_id if item_id
          
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'set') {
              xml.pubsub_('xmlns' => namespaces['pubsub']) {
                xml.publish_(:node => node){
                  xml.item_(item_options){
                    if data.respond_to?( :to_builder )
                      data.to_builder(xml.parent)
                    else
                      xml << data
                    end
                  }
                }
              }
            }
          end
          
          result = write(
            # Generate stanza
            request.to_xml
          ).xpath(
            # Pull out required parts
            '//iq[@type="result"]/pubsub:pubsub/pubsub:publish/pubsub:item',
            namespaces
          )
          if result.any?
            item_id = result.first.attr('id')
            data = request.doc.xpath("//pubsub:item/*", namespaces).to_s
            Jubjub::Pubsub::Item.new jid, node, item_id, data, @connection
          end
        end
        
        # http://xmpp.org/extensions/xep-0060.html#publisher-delete
        # <iq type='set'
        #     from='hamlet@denmark.lit/elsinore'
        #     to='pubsub.shakespeare.lit'
        #     id='retract1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        #     <retract node='princely_musings'>
        #       <item id='ae890ac52d0df67ed7cfdf51b644e901'/>
        #     </retract>
        #   </pubsub>
        # </iq>
        # 
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     to='hamlet@denmark.lit/elsinore'
        #     id='retract1'/>
        def retract(jid, node, item_id)
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'set') {
              xml.pubsub_('xmlns' => namespaces['pubsub']) {
                xml.retract_(:node => node){
                  xml.item_ :id => item_id
                }
              }
            }
          end
          
          write(
            # Generate stanza
            request.to_xml
          ).xpath('//iq[@type="result"]').any?
        end
        
        # http://xmpp.org/extensions/xep-0060.html#subscriber-retrieve
        # <iq type='get'
        #     from='francisco@denmark.lit/barracks'
        #     to='pubsub.shakespeare.lit'
        #     id='items1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        #     <items node='princely_musings'/>
        #   </pubsub>
        # </iq>
        # 
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     to='francisco@denmark.lit/barracks'
        #     id='items1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        #     <items node='princely_musings'>
        #       <item id='368866411b877c30064a5f62b917cffe'>
        #         <entry xmlns='http://www.w3.org/2005/Atom'>
        #           <title>The Uses of This World</title>
        #           <summary>
        # O, that this too too solid flesh would melt
        # Thaw and resolve itself into a dew!
        #           </summary>
        #           <link rel='alternate' type='text/html'
        #                 href='http://denmark.lit/2003/12/13/atom03'/>
        #           <id>tag:denmark.lit,2003:entry-32396</id>
        #           <published>2003-12-12T17:47:23Z</published>
        #           <updated>2003-12-12T17:47:23Z</updated>
        #         </entry>
        #       </item>
        #       ...
        #     </items>
        #   </pubsub>
        # </iq>
        def retrieve_items(jid, node)
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'get') {
              xml.pubsub_(:xmlns => namespaces['pubsub']){
                xml.items_(:node => node)
              }
            }
          end
          
          write(
            # Generate stanza
            request.to_xml
          ).xpath(
            # Pull out required parts
            '//iq[@type="result"]/pubsub:pubsub/pubsub:items/pubsub:item',
            namespaces
          ).map{|item|
            item_id = item.attr('id')
            data = item.xpath('./*').to_xml
            Jubjub::Pubsub::Item.new jid, node, item_id, data, @connection
          }
        end
        
        
        # http://xmpp.org/extensions/xep-0060.html#owner-affiliations
        # <iq type='get'
        #     from='hamlet@denmark.lit/elsinore'
        #     to='pubsub.shakespeare.lit'
        #     id='ent1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
        #     <affiliations node='princely_musings'/>
        #   </pubsub>
        # </iq>
        # 
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     to='hamlet@denmark.lit/elsinore'
        #     id='ent1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
        #     <affiliations node='princely_musings'>
        #       <affiliation jid='hamlet@denmark.lit' affiliation='owner'/>
        #       <affiliation jid='polonius@denmark.lit' affiliation='outcast'/>
        #     </affiliations>
        #   </pubsub>
        # </iq>
        def retrieve_affiliations(pubsub_jid, pubsub_node)
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => pubsub_jid, :type => 'get') {
              xml.pubsub_(:xmlns => namespaces['pubsub_owner']){
                xml.affiliations_(:node => pubsub_node)
              }
            }
          end
          
          write(
            # Generate stanza
            request.to_xml
          ).xpath(
            # Pull out required parts
            '//iq[@type="result"]/pubsub_owner:pubsub/pubsub_owner:affiliations/pubsub_owner:affiliation',
            namespaces
          ).map{|affiliation|
            jid = Jubjub::Jid.new affiliation.attr('jid')
            affiliation = affiliation.attr('affiliation')
            Jubjub::Pubsub::Affiliation.new pubsub_jid, pubsub_node, jid, affiliation, @connection
          }
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