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

          Jubjub::Response.new( write request ){|stanza|
            stanza.xpath(
              '/iq[@type="result"]/disco_items:query/disco_items:item',
              namespaces
            ).map{|item|
              jid  = item.attr('jid')
              node = item.attr('node')
              Jubjub::Pubsub.new jid, node, @connection
            }
          }.proxy_result
        end

        # http://xmpp.org/extensions/xep-0060.html#owner-create-and-configure
        # <iq type='set'
        #     from='hamlet@denmark.lit/elsinore'
        #     to='pubsub.shakespeare.lit'
        #     id='create1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        #     <create node='princely_musings'/>
        #     <configure>
        #       <x xmlns='jabber:x:data' type='submit'>
        #         <field var='FORM_TYPE' type='hidden'>
        #           <value>http://jabber.org/protocol/pubsub#node_config</value>
        #         </field>
        #         <field var='pubsub#title'><value>Princely Musings (Atom)</value></field>
        #         ...
        #       </x>
        #     </configure>
        #   </pubsub>
        # </iq>
        #
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     to='hamlet@denmark.lit/elsinore'
        #     id='create1'/>
        def create(jid, node, configuration = nil)
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'set') {
              xml.pubsub_('xmlns' => namespaces['pubsub']) {
                xml.create_('node' => node)
                if configuration
                  xml.configure_{
                    configuration.to_builder(xml.parent)
                  }
                end
              }
            }
          end

          Jubjub::Response.new( write request ){|stanza|
            success = stanza.xpath(
              # Pull out required parts
              '/iq[@type="result"]'
            ).any?
            Jubjub::Pubsub.new jid, node, @connection if success
          }.proxy_result
        end

        # http://xmpp.org/extensions/xep-0060.html#owner-configure
        # <iq type='get'
        #     from='hamlet@denmark.lit/elsinore'
        #     to='pubsub.shakespeare.lit'
        #     id='config1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
        #     <configure node='princely_musings'/>
        #   </pubsub>
        # </iq>
        #
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     to='hamlet@denmark.lit/elsinore'
        #     id='config1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
        #     <configure node='princely_musings'>
        #       <x xmlns='jabber:x:data' type='form'>
        #         <field var='FORM_TYPE' type='hidden'>
        #           <value>http://jabber.org/protocol/pubsub#node_config</value>
        #         </field>
        #         <field var='pubsub#title' type='text-single'
        #                label='A friendly name for the node'/>
        #         <field var='pubsub#deliver_notifications' type='boolean'
        #                label='Whether to deliver event notifications'>
        #           <value>true</value>
        #         </field>
        #         ...
        #       </x>
        #     </configure>
        #   </pubsub>
        # </iq>
        def default_configuration(jid)
          cache_key = [jid.to_s, @connection.jid.to_s].join(" ")
          @default_configuration ||= {}
          @default_configuration[cache_key] ||= begin
            request = Nokogiri::XML::Builder.new do |xml|
              xml.iq_(:to => jid, :type => 'get') {
                xml.pubsub_('xmlns' => namespaces['pubsub_owner']) {
                  xml.default_
                }
              }
            end

            Jubjub::Response.new( write request ){|stanza|
              config = stanza.xpath(
                # Pull out required parts
                "/iq[@type='result']/pubsub_owner:pubsub/pubsub_owner:default/x_data:x[@type='form']",
                namespaces
              )
              Jubjub::Pubsub::Configuration.new config if config
            }.proxy_result
          end
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

          Jubjub::Response.new( write request ){|stanza|
            stanza.xpath( '/iq[@type="result"]' ).any?
          }.proxy_result
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

          Jubjub::Response.new( write request ){|stanza|
            stanza.xpath( '/iq[@type="result"]' ).any?
          }.proxy_result
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

          Jubjub::Response.new( write request ){|stanza|
            result = stanza.xpath(
              '/iq[@type="result"]/pubsub:pubsub/pubsub:subscription',
              namespaces
            )
            if result.any?
              subscriber   = Jubjub::Jid.new(result.first.attr('jid'))
              subid        = result.first.attr('subid')
              subscription = result.first.attr('subscription')
              Jubjub::Pubsub::Subscription.new jid, node, subscriber, subid, subscription, @connection
            end
          }.proxy_result
        end

        # http://xmpp.org/extensions/xep-0060.html#owner-subscriptions
        # <iq type='get'
        #     from='hamlet@denmark.lit/elsinore'
        #     to='pubsub.shakespeare.lit'
        #     id='subman1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
        #     <subscriptions node='princely_musings'/>
        #   </pubsub>
        # </iq>
        #
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     to='hamlet@denmark.lit/elsinore'
        #     id='subman1'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
        #     <subscriptions node='princely_musings'>
        #       <subscription jid='hamlet@denmark.lit' subscription='subscribed'/>
        #       <subscription jid='polonius@denmark.lit' subscription='unconfigured'/>
        #       <subscription jid='bernardo@denmark.lit' subscription='subscribed' subid='123-abc'/>
        #       <subscription jid='bernardo@denmark.lit' subscription='subscribed' subid='004-yyy'/>
        #     </subscriptions>
        #   </pubsub>
        # </iq>
        def subscriptions(jid, node)
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'get') {
              xml.pubsub_('xmlns' => namespaces['pubsub_owner']) {
                xml.subscriptions_('node' => node)
              }
            }
          end

          Jubjub::Response.new( write request ){|stanza|
            stanza.xpath(
              '/iq[@type="result"]/pubsub_owner:pubsub/pubsub_owner:subscriptions/pubsub_owner:subscription',
              namespaces
            ).map{|item|
              subscriber   = Jubjub::Jid.new(item.attr('jid'))
              subid        = item.attr('subid')
              subscription = item.attr('subscription')
              Jubjub::Pubsub::Subscription.new jid, node, subscriber, subid, subscription, @connection
            }
          }.proxy_result
        end

        # http://xmpp.org/extensions/xep-0060.html#owner-subscriptions-multi
        # <iq type='set'
        #     from='hamlet@denmark.lit/elsinore'
        #     to='pubsub.shakespeare.lit'
        #     id='subman3'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
        #     <subscriptions node='princely_musings'>
        #       <subscription jid='polonius@denmark.lit' subscription='none'/>
        #       <subscription jid='bard@shakespeare.lit' subscription='subscribed'/>
        #     </subscriptions>
        #   </pubsub>
        # </iq>
        #
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     id='subman3'/>
        def set_subscriptions(jid, node, subscriptions)
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'set') {
              xml.pubsub_('xmlns' => namespaces['pubsub_owner']) {
                xml.subscriptions_('node' => node) {
                  subscriptions.each{|j,s|
                    xml.subscription(:jid => j, :subscription => s)
                  }
                }
              }
            }
          end

          Jubjub::Response.new( write request ){|stanza|
            stanza.xpath( '/iq[@type="result"]' ).any?
          }.proxy_result
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

          Jubjub::Response.new( write request ){|stanza|
            stanza.xpath( '/iq[@type="result"]' ).any?
          }.proxy_result
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

          Jubjub::Response.new( write request ){|stanza|
            result = stanza.xpath(
              '/iq[@type="result"]/pubsub:pubsub/pubsub:publish/pubsub:item',
              namespaces
            )
            if result.any?
              item_id = result.first.attr('id')
              data = request.doc.xpath("//pubsub:item/*", namespaces).to_s
              Jubjub::Pubsub::Item.new jid, node, item_id, data, @connection
            end
          }.proxy_result
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

          Jubjub::Response.new( write request ){|stanza|
            stanza.xpath( '/iq[@type="result"]' ).any?
          }.proxy_result
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

          Jubjub::Response.new( write request ){|stanza|
            stanza.xpath(
              '/iq[@type="result"]/pubsub:pubsub/pubsub:items/pubsub:item',
              namespaces
            ).map{|item|
              item_id = item.attr('id')
              data = item.xpath('./*').to_xml
              Jubjub::Pubsub::Item.new jid, node, item_id, data, @connection
            }
          }.proxy_result
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

          Jubjub::Response.new( write request ){|stanza|
            stanza.xpath(
              '/iq[@type="result"]/pubsub_owner:pubsub/pubsub_owner:affiliations/pubsub_owner:affiliation',
              namespaces
            ).map{|item|
              jid = Jubjub::Jid.new item.attr('jid')
              affiliation = item.attr('affiliation')
              Jubjub::Pubsub::Affiliation.new pubsub_jid, pubsub_node, jid, affiliation, @connection
            }
          }.proxy_result
        end

        # http://xmpp.org/extensions/xep-0060.html#owner-affiliations-modify
        # <iq type='set'
        #     from='hamlet@denmark.lit/elsinore'
        #     to='pubsub.shakespeare.lit'
        #     id='ent2'>
        #   <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
        #     <affiliations node='princely_musings'>
        #       <affiliation jid='bard@shakespeare.lit' affiliation='publisher'/>
        #     </affiliations>
        #   </pubsub>
        # </iq>
        #
        # Expected
        # <iq type='result'
        #     from='pubsub.shakespeare.lit'
        #     id='ent2'/>
        def modify_affiliations(pubsub_jid, pubsub_node, *affiliations)
          affiliations = [affiliations].flatten

          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => pubsub_jid, :type => 'set') {
              xml.pubsub_(:xmlns => namespaces['pubsub_owner']){
                xml.affiliations_(:node => pubsub_node){
                  affiliations.each {|a|
                    xml.affiliation_(:jid => a.jid, :affiliation => a.affiliation)
                  }
                }
              }
            }
          end

          Jubjub::Response.new( write request ){|stanza|
            stanza.xpath( '/iq[@type="result"]' ).any?
          }.proxy_result
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
            'pubsub_owner' => 'http://jabber.org/protocol/pubsub#owner',
            'x_data'       => 'jabber:x:data'
          }
        end

      end
    end
  end
end
