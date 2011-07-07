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
        def create(full_jid, configuration = Jubjub::Muc::Configuration.new)
          room_jid = Jubjub::Jid.new full_jid.node, full_jid.domain
          
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:type => 'set', :to => room_jid) {
              xml.query_('xmlns' => namespaces['muc_owner']){
                configuration.to_builder(xml.parent)
              }
            }
          end
          
          presence full_jid
          
          Jubjub::Response.new( write request.to_xml ){|stanza|
            success = stanza.xpath( '/iq[@type="result"]' ).any?
            Jubjub::Muc.new room_jid, nil, @connection if success
          }.proxy_result
        end
        
        # http://xmpp.org/extensions/xep-0045.html#createroom-reserved
        # <presence
        #     from='crone1@shakespeare.lit/desktop'
        #     to='darkcave@chat.shakespeare.lit/firstwitch'>
        #   <x xmlns='http://jabber.org/protocol/muc'/>
        # </presence>
        # <iq from='crone1@shakespeare.lit/desktop'
        #     id='create1'
        #     to='darkcave@chat.shakespeare.lit'
        #     type='get'>
        #   <query xmlns='http://jabber.org/protocol/muc#owner'/>
        # </iq>
        #
        # Expected
        # <iq from='darkcave@chat.shakespeare.lit'
        #     id='create1'
        #     to='crone1@shakespeare.lit/desktop'
        #     type='result'>
        #   <query xmlns='http://jabber.org/protocol/muc#owner'>
        #     <x xmlns='jabber:x:data' type='form'>
        #       <title>Configuration for "darkcave" Room</title>
        #       <instructions>
        #           Your room darkcave@macbeth has been created!
        #           The default configuration is as follows:
        #             - No logging
        #             - No moderation
        #             - Up to 20 occupants
        #             - No password required
        #             - No invitation required
        #             - Room is not persistent
        #             - Only admins may change the subject
        #             - Presence broadcasted for all users
        #           To accept the default configuration, click OK. To
        #           select a different configuration, please complete
        #           this form.
        #       </instructions>
        #       <field
        #           type='hidden'
        #           var='FORM_TYPE'>
        #         <value>http://jabber.org/protocol/muc#roomconfig</value>
        #       </field>
        #       <field
        #           label='Natural-Language Room Name'
        #           type='text-single'
        #           var='muc#roomconfig_roomname'/>
        #       <field
        #           label='Natural Language for Room Discussions'
        #           type='text-single'
        #           var='muc#roomconfig_lang'/>
        #       <field
        #           label='Enable Public Logging?'
        #           type='boolean'
        #           var='muc#roomconfig_enablelogging'>
        #         <value>0</value>
        #       </field>
        #       <field
        #           label='Maximum Number of Occupants'
        #           type='list-single'
        #           var='muc#roomconfig_maxusers'>
        #         <value>20</value>
        #         <option label='10'><value>10</value></option>
        #         <option label='20'><value>20</value></option>
        #         <option label='30'><value>30</value></option>
        #         <option label='50'><value>50</value></option>
        #         <option label='100'><value>100</value></option>
        #         <option label='None'><value>none</value></option>
        #       </field>
        #       <field
        #           label='Roles for which Presence is Broadcast'
        #           type='list-multi'
        #           var='muc#roomconfig_presencebroadcast'>
        #         <value>moderator</value>
        #         <value>participant</value>
        #         <value>visitor</value>
        #         <option label='Moderator'><value>moderator</value></option>
        #         <option label='Participant'><value>participant</value></option>
        #         <option label='Visitor'><value>visitor</value></option>
        #       </field>
        #       <field
        #           label='Roles and Affiliations that May Retrieve Member List'
        #           type='list-multi'
        #           var='muc#roomconfig_getmemberlist'>
        #         <value>moderator</value>
        #         <value>participant</value>
        #         <value>visitor</value>
        #         <option label='Moderator'><value>moderator</value></option>
        #         <option label='Participant'><value>participant</value></option>
        #         <option label='Visitor'><value>visitor</value></option>
        #       </field>
        #       <field
        #           label='Make Room Publicly Searchable?'
        #           type='boolean'
        #           var='muc#roomconfig_publicroom'>
        #         <value>1</value>
        #       </field>
        #       <field
        #           label='Make Room Persistent?'
        #           type='boolean'
        #           var='muc#roomconfig_persistentroom'>
        #         <value>0</value>
        #       </field>
        #       <field type='fixed'>
        #         <value>
        #           If a password is required to enter this room,
        #           you must specify the password below.
        #         </value>
        #       </field>
        #       <field
        #           label='Password'
        #           type='text-private'
        #           var='muc#roomconfig_roomsecret'/>
        #       <field
        #           label='Who May Discover Real JIDs?'
        #           type='list-single'
        #           var='muc#roomconfig_whois'>
        #         <option label='Moderators Only'>
        #           <value>moderators</value>
        #         </option>
        #         <option label='Anyone'>
        #           <value>anyone</value>
        #         </option>
        #       </field>
        #       <field type='fixed'>
        #         <value>
        #           You may specify additional people who have
        #           administrative privileges in the room. Please
        #           provide one Jabber ID per line.
        #         </value>
        #       </field>
        #       <field
        #           label='Room Admins'
        #           type='jid-multi'
        #           var='muc#roomconfig_roomadmins'/>
        #       <field type='fixed'>
        #         <value>
        #           You may specify additional owners for this
        #           room. Please provide one Jabber ID per line.
        #         </value>
        #       </field>
        #       <field
        #           label='Room Owners'
        #           type='jid-multi'
        #           var='muc#roomconfig_roomowners'/>
        #     </x>
        #   </query>
        # </iq>
        def configuration(full_jid)
          room_jid = Jubjub::Jid.new full_jid.node, full_jid.domain
          
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => room_jid, :type => 'get') {
              xml.query_('xmlns' => namespaces['muc_owner'])
            }
          end
          
          presence full_jid
          
          Jubjub::Response.new( write request.to_xml ){|stanza|
            config = stanza.xpath(
              "/iq[@type='result']/muc_owner:query/x_data:x[@type='form']",
              namespaces
            )
            Jubjub::Muc::Configuration.new config if config
          }.proxy_result
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
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'set') {
              xml.query_('xmlns' => namespaces['muc_owner']){
                xml.destroy_
              }
            }
          end
          
          Jubjub::Response.new( write request.to_xml ){|stanza|
            stanza.xpath( '/iq[@type="result"]' ).any?
          }.proxy_result
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
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'get') {
              xml.query_('xmlns' => namespaces['disco_items'])
            }
          end
                    
          Jubjub::Response.new( write request.to_xml ){|stanza|
            stanza.xpath(
              '/iq[@type="result"]/disco_items:query/disco_items:item',
              namespaces
            ).map{|item|
              # Convert to Jubjub object
              Jubjub::Muc.new item.attr('jid'), item.attr('name'), @connection
            }
          }.proxy_result
        end
        
        # http://xmpp.org/extensions/xep-0045.html#modifymember
        # <iq from='crone1@shakespeare.lit/desktop'
        #     id='member3'
        #     to='coven@chat.shakespeare.lit'
        #     type='get'>
        #   <query xmlns='http://jabber.org/protocol/muc#admin'>
        #     <item affiliation='member'/>
        #   </query>
        # </iq>
        # 
        # Expected
        # <iq from='coven@chat.shakespeare.lit'
        #     id='member3'
        #     to='crone1@shakespeare.lit/desktop'
        #     type='result'>
        #   <query xmlns='http://jabber.org/protocol/muc#admin'>
        #     <item affiliation='member'
        #           jid='hag66@shakespeare.lit'
        #           nick='thirdwitch'
        #           role='participant'/>
        #   </query>
        # </iq>
        def retrieve_affiliations(jid, affiliation)
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => jid, :type => 'get') {
              xml.query_('xmlns' => namespaces['muc_admin']) {
                xml.item_(:affiliation => affiliation)
              }
            }
          end
          
          Jubjub::Response.new( write request.to_xml ){|stanza|
            stanza.xpath(
              '/iq[@type="result"]/muc_admin:query/muc_admin:item',
              namespaces
            ).map{|item|
              # Convert to Jubjub object
              Jubjub::Muc::Affiliation.new jid, item.attr('jid'), item.attr('nick'), item.attr('role'), item.attr('affiliation'), @connection
            }
          }.proxy_result
        end
        
        # http://xmpp.org/extensions/xep-0045.html#grantmember
        # <iq from='crone1@shakespeare.lit/desktop'
        #     id='member1'
        #     to='coven@chat.shakespeare.lit'
        #     type='set'>
        #   <query xmlns='http://jabber.org/protocol/muc#admin'>
        #     <item affiliation='member'
        #           jid='hag66@shakespeare.lit'/>
        #   </query>
        # </iq>
        #
        # Expected
        # <iq from='coven@chat.shakespeare.lit'
        #     id='member1'
        #     to='crone1@shakespeare.lit/desktop'
        #     type='result'/>
        def modify_affiliations(muc_jid, *affiliations)
          affiliations = [affiliations].flatten
          
          request = Nokogiri::XML::Builder.new do |xml|
            xml.iq_(:to => muc_jid, :type => 'set') {
              xml.query_('xmlns' => namespaces['muc_admin']) {
                affiliations.each {|a|
                  xml.item_(:affiliation => a.affiliation, :jid => a.jid)
                }
              }
            }
          end
          
          Jubjub::Response.new( write request.to_xml ){|stanza|
            stanza.xpath( '/iq[@type="result"]' ).any?
          }.proxy_result
        end
        
        # http://xmpp.org/extensions/xep-0045.html#exit
        # <presence
        #     from='hag66@shakespeare.lit/pda'
        #     to='darkcave@chat.shakespeare.lit/thirdwitch'
        #     type='unavailable'/>
        def exit(full_jid)
          presence full_jid, :unavailable
        end
        
      private
      
        def presence(full_jid, availability = :available)
          options = { :to => full_jid }
          options[:type] = availability unless availability == :available
          
          request = Nokogiri::XML::Builder.new do |xml|
            xml.presence_(options) {
              xml.x_('xmlns' => 'http://jabber.org/protocol/muc')
            }
          end
          
          write request.to_xml
        end
        
        def namespaces
          {
            'disco_items' => 'http://jabber.org/protocol/disco#items',
            'muc_owner'   => "http://jabber.org/protocol/muc#owner",
            'muc_admin'   => "http://jabber.org/protocol/muc#admin",
            'x_data'      => 'jabber:x:data'
          }
        end
        
      end
    end
  end
end