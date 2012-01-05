require 'spec_helper'

describe Jubjub::Connection::XmppGateway do

  before do
    @jid = Jubjub::Jid.new('theozaurus@theo-template.local')
    @connection = Jubjub::Connection::XmppGateway.new(@jid, 'secret', {:host => '127.0.0.1', :port => '8000'})
  end

  describe "pubsub" do

    describe "create" do
      use_vcr_cassette 'pubsub create', :record => :new_episodes

      it "return a Jubjub::Pubsub" do
        @pubsub = @connection.pubsub.create 'pubsub.theo-template.local', 'node_1'

        @pubsub.should be_a_kind_of_response_proxied Jubjub::Pubsub
        @pubsub.jid.should == Jubjub::Jid.new('pubsub.theo-template.local')
        @pubsub.node.should == 'node_1'
      end

      after do
        # Clean up the node
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_1'
      end
    end

    describe "default_configuration" do
      use_vcr_cassette 'pubsub default configuration', :record => :new_episodes

      it "should return a Jubjub::Pubsub::Configuration" do
        expected_config = {
          "pubsub#deliver_payloads" => { :type => "boolean", :value => "1", :label => "Deliver payloads with event notifications" },
          "pubsub#subscribe" => { :type => "boolean", :value => "1", :label => "Whether to allow subscriptions" },
          "pubsub#notify_delete" => { :type => "boolean", :value => "0", :label => "Notify subscribers when the node is deleted" },
          "pubsub#deliver_notifications" => { :type => "boolean", :value => "1", :label => "Deliver event notifications" },
          "pubsub#persist_items" => { :type => "boolean", :value => "1", :label => "Persist items to storage" },
          "pubsub#presence_based_delivery" => { :type => "boolean", :value => "0", :label => "Only deliver notifications to available users" },
          "pubsub#notify_retract"  => { :type => "boolean", :value => "1", :label => "Notify subscribers when items are removed from the node" },
          "pubsub#notify_config" => { :type => "boolean", :value => "0", :label => "Notify subscribers when the node configuration changes" },
          "pubsub#max_payload_size"  => { :type => "text-single", :value => "60000", :label => "Max payload size in bytes" },
          "pubsub#title" => { :type => "text-single", :value => "", :label => "A friendly name for the node" },
          "pubsub#max_items" => { :type => "text-single", :value => "10", :label => "Max # of items to persist" },
          "pubsub#collection" => { :type => "text-multi", :value => [], :label => "The collections with which a node is affiliated" },
          "pubsub#roster_groups_allowed" => { :type => "list-multi", :value => [], :label => "Roster groups allowed to subscribe" },
          "FORM_TYPE"  => { :type => "hidden", :value => "http://jabber.org/protocol/pubsub#node_config", :label => "" },
          "pubsub#send_last_published_item" => {
            :type => "list-single",
            :value => "on_sub_and_presence",
            :label => "When to send the last published item",
            :options => [
              { :value => "never",               :label => nil },
              { :value => "on_sub",              :label => nil },
              { :value => "on_sub_and_presence", :label => nil }]},
          "pubsub#access_model" => {
            :type    => "list-single",
            :value   => "open",
            :label   => "Specify the access model",
            :options => [
              { :value => "open",      :label => nil },
              { :value => "authorize", :label => nil },
              { :value => "presence",  :label => nil },
              { :value => "roster",    :label => nil },
              { :value => "whitelist", :label => nil }]},
          "pubsub#publish_model" => {
            :type => "list-single",
            :value => "publishers",
            :label => "Specify the publisher model",
            :options => [
              { :value => "publishers",  :label => nil },
              { :value => "subscribers", :label => nil },
              { :value => "open",        :label => nil }]},
          "pubsub#notification_type" => {
            :type    => "list-single",
            :value   => "headline",
            :label   => "Specify the event message type",
            :options => [
              { :value => "headline", :label => nil },
              { :value => "normal",   :label => nil }]}
        }

        config = @connection.pubsub.default_configuration 'pubsub.theo-template.local'

        config.should be_a_kind_of_response_proxied Jubjub::Pubsub::Configuration
        config.should == Jubjub::Pubsub::Configuration.new( expected_config )
      end
    end

    describe "destroy" do
      use_vcr_cassette 'pubsub destroy', :record => :new_episodes

      before do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_1'
      end

      it "should send correct stanza" do
        # will attempt to create new vcr cassette if the stanza is wrong
        # relies on cassette being manually checked
        @connection.pubsub.destroy('pubsub.theo-template.local', 'node_1').should be_true
      end
    end

    describe "purge" do
      use_vcr_cassette 'pubsub purge', :record => :new_episodes

      before do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_pubsub_purge'
      end

      it "should send correct stanza" do
        # will attempt to create new vcr cassette if the stanza is wrong
        # relies on cassette being manually checked
        @connection.pubsub.purge('pubsub.theo-template.local', 'node_pubsub_purge').should be_true
      end

      after do
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_pubsub_purge'
      end
    end

    describe "list" do

      use_vcr_cassette 'pubsub list', :record => :new_episodes

      before do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_1'
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_2'
      end

      it "return an array of Jubjub::Muc" do
        list = @connection.pubsub.list 'pubsub.theo-template.local'
        list.should be_a_kind_of_response_proxied Array

        list.map{|item| item.node }.to_set.should == ['node_1', 'node_2'].to_set
      end

      after do
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_1'
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_2'
      end

    end

    describe "destroy with redirect" do
      use_vcr_cassette 'pubsub destroy with redirect', :record => :new_episodes

      before do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_1'
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_2'
      end

      it "should support redirects" do
        @connection.pubsub.destroy('pubsub.theo-template.local', 'node_1', 'pubsub.theo-template.local', 'node_2').should be_true
      end

      after do
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_2'
      end
    end

    describe "subscribe" do
      use_vcr_cassette 'pubsub subscribe', :record => :new_episodes

      before do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_1'
      end

      it "return a Jubjub::Pubsub::Subscription" do
        @subscription = @connection.pubsub.subscribe( 'pubsub.theo-template.local', 'node_1' )

        @subscription.should be_a_kind_of_response_proxied Jubjub::Pubsub::Subscription
        @subscription.jid.should == Jubjub::Jid.new('pubsub.theo-template.local')
        @subscription.node.should == 'node_1'
        @subscription.subscriber.should == @jid
        @subscription.subscription.should == "subscribed"
        @subscription.subid.should be_kind_of(String)
      end

      after do
        # Clean up the node
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_1'
      end

    end

    describe "unsubscribe" do

      use_vcr_cassette 'pubsub unsubscribe', :record => :new_episodes

      before do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_1'
        @connection.pubsub.subscribe 'pubsub.theo-template.local', 'node_1'
      end

      it "return true" do
        @connection.pubsub.unsubscribe( 'pubsub.theo-template.local', 'node_1' ).should be_true
      end

      after do
        # Clean up the node
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_1'
      end

    end

    describe "unsubscribe with subid" do
      use_vcr_cassette 'pubsub unsubscribe with subid', :record => :new_episodes

      before do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_1'
        @subscription = @connection.pubsub.subscribe 'pubsub.theo-template.local', 'node_1'
      end

      it "return true" do
        @connection.pubsub.unsubscribe( 'pubsub.theo-template.local', 'node_1', @subscription.subid ).should be_true
      end

      after do
        # Clean up the node
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_1'
      end

    end

    describe "publish" do
      use_vcr_cassette 'pubsub setup node', :record => :new_episodes

      before do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_1'
      end

      describe "with id" do
        use_vcr_cassette 'pubsub publish with id', :record => :new_episodes

        it "should return a Jubjub::Pubsub::Item" do
          i = @connection.pubsub.publish 'pubsub.theo-template.local', 'node_1', Jubjub::DataForm.new, '123'
          i.should be_a_kind_of_response_proxied Jubjub::Pubsub::Item
          i.item_id.should == '123'
          i.data.should == "<x xmlns=\"jabber:x:data\" type=\"submit\"/>"
        end

      end

      describe "with string payload" do
        use_vcr_cassette 'pubsub publish with string payload', :record => :new_episodes

        it "should return a Jubjub::Pubsub::Item" do
          item = "<x xmlns=\"jabber:x:data\" type=\"submit\"><field var=\"foo\"><value>true</value></field></x>"
          i = @connection.pubsub.publish 'pubsub.theo-template.local', 'node_1', item
          i.should be_a_kind_of_response_proxied Jubjub::Pubsub::Item
          i.item_id.should be_a_kind_of String
          i.data.should == "<x xmlns=\"jabber:x:data\" type=\"submit\">\n  <field var=\"foo\">\n    <value>true</value>\n  </field>\n</x>"
        end

      end

      describe "with dataform payload" do
        use_vcr_cassette 'pubsub publish with dataform payload', :record => :new_episodes

        it "should return a Jubjub::Pubsub::Item" do
          i = @connection.pubsub.publish 'pubsub.theo-template.local', 'node_1', Jubjub::DataForm.new({ :foo => {:type => "boolean", :value => true }})
          i.should be_a_kind_of_response_proxied Jubjub::Pubsub::Item
          i.item_id.should be_a_kind_of String
          i.data.should == "<x xmlns=\"jabber:x:data\" type=\"submit\">\n  <field var=\"foo\">\n    <value>true</value>\n  </field>\n</x>"
        end

      end

      after do
        # Clean up the node
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_1'
      end

    end

    describe "retract" do
      use_vcr_cassette 'pubsub retract', :record => :new_episodes

      before do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_pubsub_retract'
      end

      it "should return true when successful" do
        item = @connection.pubsub.publish 'pubsub.theo-template.local', 'node_pubsub_retract', Jubjub::DataForm.new()

        @connection.pubsub.retract( 'pubsub.theo-template.local', 'node_pubsub_retract', item.item_id ).should be_true
      end

      it "should return false when not successful" do
        @connection.pubsub.retract( 'pubsub.theo-template.local', 'node_pubsub_retract', "wibble" ).should equal(false)
      end

      after do
        # Clean up the node
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_pubsub_retract'
      end
    end

    describe "retrieve_items" do
      use_vcr_cassette 'pubsub retrieve items', :record => :new_episodes

      before do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_retrieve_items'
        @connection.pubsub.publish 'pubsub.theo-template.local', 'node_retrieve_items', Jubjub::DataForm.new(:bar => {:type => :boolean, :value => true}), 'efg'
        @connection.pubsub.publish 'pubsub.theo-template.local', 'node_retrieve_items', Jubjub::DataForm.new(:foo => {:type => :boolean, :value => false}), 'abc'
      end

      it "should return array of Pubsub::Item when successful" do
        expected = [
          Jubjub::Pubsub::Item.new( 'pubsub.theo-template.local', 'node_retrieve_items', 'abc', "<x xmlns=\"jabber:x:data\" type=\"submit\">\n          <field var=\"foo\">\n            <value>false</value>\n          </field>\n        </x>", @connection ),
          Jubjub::Pubsub::Item.new( 'pubsub.theo-template.local', 'node_retrieve_items', 'efg', "<x xmlns=\"jabber:x:data\" type=\"submit\">\n          <field var=\"bar\">\n            <value>true</value>\n          </field>\n        </x>", @connection )
        ]

        @connection.pubsub.retrieve_items( 'pubsub.theo-template.local', 'node_retrieve_items' ).should == expected
      end

      it "should return empty array when not successful" do
        @connection.pubsub.retrieve_items( 'pubsub.theo-template.local', 'node_retrieve_items_wibble' ).should == []
      end

      after do
        # Clean up the node
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_retrieve_items'
      end
    end

    describe "retrieve_affiliations" do
      use_vcr_cassette 'pubsub retrieve affiliations', :record => :new_episodes

      it "should return array of Pubsub::Affiliation when successful" do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_retrieve_affiliations'

        expected = [
          Jubjub::Pubsub::Affiliation.new(
            'pubsub.theo-template.local',
            'node_retrieve_affiliations',
            Jubjub::Jid.new('theozaurus@theo-template.local'),
            'owner',
            @connection
          )
        ]

        @connection.pubsub.retrieve_affiliations( 'pubsub.theo-template.local', 'node_retrieve_affiliations' ).should == expected

        # Clean up the node
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_retrieve_affiliations'
      end

      it "should return empty array when not successful" do
        @connection.pubsub.retrieve_affiliations( 'pubsub.theo-template.local', 'made-up' ).should == []
      end
    end

    describe "modify_affiliations" do
      use_vcr_cassette 'pubsub modify affiliations', :record => :new_episodes

      it "should return true when successful" do
        pubsub = 'pubsub.theo-template.local'
        node = 'node_modify_affiliations_1'
        @connection.pubsub.create pubsub, node

        affiliation = Jubjub::Pubsub::Affiliation.new pubsub, node, 'theozaurus@theo-template.local', 'owner', @connection
        @connection.pubsub.modify_affiliations( pubsub, node, affiliation).should equal(true)

        @connection.pubsub.destroy pubsub, node
      end

      it "should allow affiliations to be specified as an array" do
        pubsub = 'pubsub.theo-template.local'
        node = 'node_modify_affiliations_2'
        @connection.pubsub.create pubsub, node

        affiliation_1 = Jubjub::Pubsub::Affiliation.new pubsub, node, 'theozaurus@theo-template.local','owner', @connection
        affiliation_2 = Jubjub::Pubsub::Affiliation.new pubsub, node, 'trex@theo-template.local', 'publisher', @connection
        @connection.pubsub.modify_affiliations pubsub, node, [affiliation_1, affiliation_2]

        @connection.pubsub.destroy pubsub, node
      end

      it "should allow affiliations to be specified as arguments" do
        pubsub = 'pubsub.theo-template.local'
        node = 'node_modify_affiliations_3'
        @connection.pubsub.create pubsub, node

        affiliation_1 = Jubjub::Pubsub::Affiliation.new pubsub, node, 'theozaurus@theo-template.local', 'owner', @connection
        affiliation_2 = Jubjub::Pubsub::Affiliation.new pubsub, node, 'trex@theo-template.local', 'publisher', @connection
        @connection.pubsub.modify_affiliations pubsub, node, affiliation_1, affiliation_2

        @connection.pubsub.destroy pubsub, node
      end

      it "should return false if unsuccessful" do
        pubsub = 'pubsub.theo-template.local'
        node = 'node_modify_affiliations_4'
        @connection.pubsub.create pubsub, node

        affiliation = Jubjub::Pubsub::Affiliation.new pubsub, node, 'theozaurus@theo-template.local', 'WIBBLE', @connection
        @connection.pubsub.modify_affiliations( pubsub, node, affiliation ).should equal(false)

        @connection.pubsub.destroy pubsub, node
      end
    end

  end

end
