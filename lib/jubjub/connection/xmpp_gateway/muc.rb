require 'jubjub/connection/xmpp_gateway/helper'
require 'jubjub/muc'

module Jubjub
  module Connection
    class XmppGateway
      class Muc
        
        include Helper
        
        def initialize(connection)
          @connection = connection
        end
        
        # http://xmpp.org/extensions/xep-0045.html#createroom-instant
        # <presence
        #     from='crone1@shakespeare.lit/desktop'
        #     to='darkcave@chat.shakespeare.lit/firstwitch'>
        #   <x xmlns='http://jabber.org/protocol/muc'/>
        # </presence> 
        # <iq from='crone1@shakespeare.lit/desktop'
        #     id='create1'
        #     to='darkcave@chat.shakespeare.lit'
        #     type='set'>
        #   <query xmlns='http://jabber.org/protocol/muc#owner'>
        #     <x xmlns='jabber:x:data' type='submit'/>
        #   </query>
        # </iq>
        #
        # Expected
        # <iq from='darkcave@chat.shakespeare.lit'
        #     id='create2'
        #     to='crone1@shakespeare.lit/desktop'
        #     type='result'/>
        #
        def create(full_jid)
          write(
            # Prepare room
            "<presence to='#{full_jid}'>" +
            "  <x xmlns='http://jabber.org/protocol/muc'/>" +
            "</presence>"
          )
          
          room_jid = Jubjub::Jid.new full_jid.node, full_jid.domain
          success = write(
            # Open room
            "<iq to='#{room_jid}'" +
            "    type='set'>" +
            "  <query xmlns='http://jabber.org/protocol/muc#owner'>" +
            "    <x xmlns='jabber:x:data' type='submit'/>" +
            "  </query>" +
            "</iq>"
          ).xpath(
            # Check for valid response
            '//iq[@type="result"]'
          ).any?
          Jubjub::Muc.new room_jid, nil, @connection if success
        end
        
        # http://xmpp.org/extensions/xep-0045.html#destroyroom
        # <iq from='crone1@shakespeare.lit/desktop'
        #     id='begone'
        #     to='heath@chat.shakespeare.lit'
        #     type='set'>
        #   <query xmlns='http://jabber.org/protocol/muc#owner'>
        #     <destroy jid='darkcave@chat.shakespeare.lit'>
        #       <reason>Macbeth doth come.</reason>
        #     </destroy>
        #   </query>
        # </iq>
        #
        # Expected
        # <iq from='heath@chat.shakespeare.lit'
        #     id='begone'
        #     to='crone1@shakespeare.lit/desktop'
        #     type='result'/>
        def destroy(jid)
          write(
            # Generate stanza
            "<iq to='#{jid}'" +
            "    type='set'>" +
            "  <query xmlns='http://jabber.org/protocol/muc#owner'>" +
            "    <destroy/>" +
            "  </query>" +
            "</iq>"
          ).xpath(
            # Check for valid response
            '//iq[@type="result"]'
          ).any?
        end
        
        # http://xmpp.org/extensions/xep-0045.html#disco-rooms
        # <iq from='hag66@shakespeare.lit/pda'
        #     id='disco2'
        #     to='chat.shakespeare.lit'
        #     type='get'>
        #   <query xmlns='http://jabber.org/protocol/disco#items'/>
        # </iq>
        #
        # Expected
        # <iq from='chat.shakespeare.lit'
        #     id='disco2'
        #     to='hag66@shakespeare.lit/pda'
        #     type='result'>
        #   <query xmlns='http://jabber.org/protocol/disco#items'>
        #     <item jid='heath@chat.shakespeare.lit'
        #           name='A Lonely Heath'/>
        #     <item jid='darkcave@chat.shakespeare.lit'
        #           name='A Dark Cave'/>
        #     <item jid='forres@chat.shakespeare.lit'
        #           name='The Palace'/>
        #     <item jid='inverness@chat.shakespeare.lit'
        #           name='Macbeth&apos;s Castle'/>
        #   </query>
        # </iq>
        def list(jid)
          write(
            # Generate stanza
            "<iq to='#{jid}'" +
            "    type='get'>" +
            "  <query xmlns='http://jabber.org/protocol/disco#items'/>" +
            "</iq>"
          ).xpath(
            # Pull out required parts
            '//iq[@type="result"]/disco_items:query/disco_items:item',
            {'disco_items' => 'http://jabber.org/protocol/disco#items'}
          ).map{|item| 
            # Convert to Jubjub object
            Jubjub::Muc.new item.attr('jid'), item.attr('name'), @connection
          }
        end
        
      end
    end
  end
end