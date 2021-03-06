require 'spec_helper'

describe Jubjub::Connection::XmppGateway do

  before do
    @connection = Jubjub::Connection::XmppGateway.new('theozaurus@xmpp.local','secret', {:host => '127.0.0.1', :port => '8000'})
  end

  describe "muc" do

    describe "create" do

      use_vcr_cassette 'muc create', :record => :new_episodes

      it "return a Jubjub::Muc" do
        @room = @connection.muc.create( Jubjub::Jid.new 'room@conference.xmpp.local/nick' )
        @room.should be_a_kind_of_response_proxied Jubjub::Muc
        @room.jid.should == Jubjub::Jid.new( 'room@conference.xmpp.local' )
      end

      after do
        @room.destroy
      end

    end

    describe "create with configuration" do

      use_vcr_cassette 'muc create with configuration', :record => :new_episodes

      it "return a Jubjub::Muc" do
        @config = Jubjub::Muc::Configuration.new("allow_query_users" => { :type => "boolean", :value => "1", :label => "Allow users to query other users" })

        @room = @connection.muc.create( Jubjub::Jid.new( 'room@conference.xmpp.local/nick' ), @config )
        @room.should be_a_kind_of_response_proxied Jubjub::Muc
        @room.jid.should == Jubjub::Jid.new( 'room@conference.xmpp.local' )
      end

      after do
        @room.destroy
      end

    end

    describe "configuration" do

      use_vcr_cassette 'muc configuration', :record => :new_episodes

      before do
        @jid = Jubjub::Jid.new 'configuration@conference.xmpp.local/nick'
        @room = @connection.muc.create @jid
      end

      it "return a Jubjub::Muc::Configuration" do
        config = @connection.muc.configuration @jid

        expected_config = {
          "allow_query_users"                     => { :type => "boolean", :value => "1", :label => "Allow users to query other users" },
          "allow_private_messages"                => { :type => "boolean", :value => "1", :label => "Allow users to send private messages" },
          "muc#roomconfig_publicroom"             => { :type => "boolean", :value => "1", :label => "Make room public searchable" },
          "muc#roomconfig_allowinvites"           => { :type => "boolean", :value => "0", :label => "Allow users to send invites" },
          "muc#roomconfig_allowvisitornickchange" => { :type => "boolean", :value => "1", :label => "Allow visitors to change nickname" },
          "muc#roomconfig_membersonly"            => { :type => "boolean", :value => "0", :label => "Make room members-only" },
          "muc#roomconfig_persistentroom"         => { :type => "boolean", :value => "0", :label => "Make room persistent" },
          "members_by_default"                    => { :type => "boolean", :value => "1", :label => "Default users as participants" },
          "muc#roomconfig_passwordprotectedroom"  => { :type => "boolean", :value => "0", :label => "Make room password protected" },
          "public_list"                           => { :type => "boolean", :value => "1", :label => "Make participants list public" },
          "muc#roomconfig_changesubject"          => { :type => "boolean", :value => "1", :label => "Allow users to change the subject" },
          "muc#roomconfig_moderatedroom"          => { :type => "boolean", :value => "1", :label => "Make room moderated" },
          "muc#roomconfig_allowvisitorstatus"     => { :type => "boolean", :value => "1", :label => "Allow visitors to send status text in presence updates" },
          "muc#roomconfig_roomdesc"   => { :type => "text-single",  :value => "", :label => "Room description" },
          "muc#roomconfig_roomname"   => { :type => "text-single",  :value => "", :label => "Room title" },
          "muc#roomconfig_roomsecret" => { :type => "text-private", :value => "", :label => "Password" },
          "FORM_TYPE"                 => { :type => "hidden", :value => "http://jabber.org/protocol/muc#roomconfig", :label => nil },
          "muc#roomconfig_whois" => {
            :type    => "list-single",
            :value   => "moderators",
            :label   => "Present real Jabber IDs to",
            :options => [
              { :value => "moderators", :label => "moderators only" },
              { :value => "anyone",     :label => "anyone"          }]},
          "muc#roomconfig_maxusers" => {
            :type    => "list-single",
            :value   => "200",
            :label   => "Maximum Number of Occupants",
            :options => [
              { :value => "5",   :label => "5"   },
              { :value => "10",  :label => "10"  },
              { :value => "20",  :label => "20"  },
              { :value => "30",  :label => "30"  },
              { :value => "50",  :label => "50"  },
              { :value => "100", :label => "100" },
              { :value => "200", :label => "200" }]}
        }

        config.should == Jubjub::Muc::Configuration.new(expected_config)
      end

      after do
        @room.destroy
      end

    end

    describe "list" do

      use_vcr_cassette 'muc list', :record => :new_episodes

      before do
        @connection.muc.create Jubjub::Jid.new( 'test_1@conference.xmpp.local/nick' )
        @connection.muc.create Jubjub::Jid.new( 'test_2@conference.xmpp.local/nick' )
      end

      it "return an array of Jubjub::Muc" do
        list = @connection.muc.list( Jubjub::Jid.new 'conference.xmpp.local' )
        list.should be_a_kind_of_response_proxied Array

        list.size.should eql(2)
        list[0].should be_a_kind_of Jubjub::Muc
        list[0].jid.should == Jubjub::Jid.new( 'test_1@conference.xmpp.local' )
        list[1].should be_a_kind_of Jubjub::Muc
        list[1].jid.should == Jubjub::Jid.new( 'test_2@conference.xmpp.local' )
      end

    end

    describe "retrieve_affiliations" do

      use_vcr_cassette 'muc retrieve_affiliations', :record => :new_episodes

      before do
        @room_full = Jubjub::Jid.new( 'retrieve_affiliations@conference.xmpp.local/theozaurus' )
        @room = Jubjub::Jid.new @room_full.node, @room_full.domain

        @connection.muc.create @room_full
      end

      it "return an array of Jubjub::Muc::Affiliation" do
        list = @connection.muc.retrieve_affiliations @room, 'owner'
        list.should be_a_kind_of_response_proxied Array

        list.size.should eql(1)
        list[0].should be_a_kind_of Jubjub::Muc::Affiliation
        list[0].jid.should == Jubjub::Jid.new( 'theozaurus@xmpp.local' )
        list[0].role.should == nil
        list[0].affiliation.should == "owner"
        list[0].nick.should == nil
      end

      after do
        @connection.muc.destroy @room
      end

    end

    describe "modify_affiliations" do

      use_vcr_cassette 'muc modify_affiliations', :record => :new_episodes

      it "should return true when successful" do
        room_full = Jubjub::Jid.new 'modify_affiliations_1@conference.xmpp.local/foo'
        room = Jubjub::Jid.new room_full.node, room_full.domain
        @connection.muc.create room_full

        affiliation = muc_affiliation_factory :muc_jid => room,
                                              :jid => 'ed@xmpp.local',
                                              :affiliation => 'owner',
                                              :connection => @connection

        @connection.muc.modify_affiliations( room, affiliation).should equal(true)

        @connection.muc.destroy room
      end

      it "should allow affiliations to be specified as an array" do
        room_full = Jubjub::Jid.new 'modify_affiliations_2@conference.xmpp.local/foo'
        room = Jubjub::Jid.new room_full.node, room_full.domain
        @connection.muc.create room_full

        affiliation_1 = muc_affiliation_factory :muc_jid => room,
                                                :jid => 'ed@xmpp.local',
                                                :affiliation => 'owner',
                                                :connection => @connection
        affiliation_2 = muc_affiliation_factory :muc_jid => room,
                                                :jid => 'bob@xmpp.local',
                                                :affiliation => 'member',
                                                :connection => @connection

        @connection.muc.modify_affiliations room, [affiliation_1, affiliation_2]

        @connection.muc.destroy room
      end

      it "should allow affiliations to be specified as arguments" do
        room_full = Jubjub::Jid.new 'modify_affiliations_3@conference.xmpp.local/foo'
        room = Jubjub::Jid.new room_full.node, room_full.domain
        @connection.muc.create room_full

        affiliation_1 = muc_affiliation_factory :muc_jid => room,
                                                :jid => 'ed@xmpp.local',
                                                :affiliation => 'owner',
                                                :connection => @connection
        affiliation_2 = muc_affiliation_factory :muc_jid => room,
                                                :jid => 'bob@xmpp.local',
                                                :affiliation => 'member',
                                                :connection => @connection

        @connection.muc.modify_affiliations room, affiliation_1, affiliation_2

        @connection.muc.destroy room
      end

      it "should return false if unsuccessful" do
        room_full = Jubjub::Jid.new 'modify_affiliations_4@conference.xmpp.local/foo'
        room = Jubjub::Jid.new room_full.node, room_full.domain
        @connection.muc.create room_full

        affiliation = muc_affiliation_factory :muc_jid => room,
                                              :jid => 'ed@xmpp.local',
                                              :affiliation => 'WIBBLE',
                                              :connection => @connection

        @connection.muc.modify_affiliations( room, affiliation ).should equal(false)

        @connection.muc.destroy room
      end

    end

    describe "message" do
      use_vcr_cassette 'muc message', :record => :new_episodes

      before do
        @full_jid = Jubjub::Jid.new 'message@conference.xmpp.local/nick'
        @jid = Jubjub::Jid.new 'message@conference.xmpp.local'
        @connection.muc.create(@full_jid)
      end

      it "should send correct stanza" do
        # will attempt to create new vcr cassette if the stanza is wrong
        # relies on cassette being manually checked
        @connection.muc.message(@jid, "Jubjub here!")
      end

      after do
        # Just incase the room is persistent
        @connection.muc.destroy(@jid)
      end

    end

    describe "exit" do
      use_vcr_cassette 'muc exit', :record => :new_episodes

      before do
        @full_jid = Jubjub::Jid.new 'extra@conference.xmpp.local/nick'
        @jid = Jubjub::Jid.new 'extra@conference.xmpp.local'
        @connection.muc.create(@full_jid)
      end

      it "should send correct stanza" do
        # will attempt to create new vcr cassette if the stanza is wrong
        # relies on cassette being manually checked
        @connection.muc.exit(@full_jid)
      end

      after do
        # Just incase the room is persistent
        @connection.muc.destroy(@jid)
      end

    end

    describe "destroy" do

      use_vcr_cassette 'muc destroy', :record => :new_episodes

      before do
        @jid      = Jubjub::Jid.new 'extra@conference.xmpp.local'
        @full_jid = Jubjub::Jid.new 'extra@conference.xmpp.local/nick'
        @connection.muc.create @full_jid
      end

      it "return true" do
        @connection.muc.destroy( @jid ).should be_true
      end

    end

  end

end
