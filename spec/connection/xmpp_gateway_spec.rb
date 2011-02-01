require 'spec_helper'

describe Jubjub::Connection::XmppGateway do
  
  before do
    @connection = Jubjub::Connection::XmppGateway.new('theozaurus@theo-template.local','secret', {:host => '127.0.0.1', :port => '8000'})
  end
  
  describe "muc" do
    
    describe "create" do
      
      use_vcr_cassette 'muc create', :record => :new_episodes
      
      it "return a Jubjub::Muc" do
        @room = @connection.muc.create( Jubjub::Jid.new 'room@conference.theo-template.local/nick' )
        @room.should be_a_kind_of Jubjub::Muc
        @room.jid.should == Jubjub::Jid.new( 'room@conference.theo-template.local' )
      end
      
      after do
        @room.destroy
      end
      
    end
    
    describe "create with configuration" do
      
      use_vcr_cassette 'muc create with configuration', :record => :new_episodes
      
      it "return a Jubjub::Muc" do
        @config = Jubjub::MucConfiguration.new("allow_query_users" => { :type => "boolean", :value => "1", :label => "Allow users to query other users" })
        
        @room = @connection.muc.create( Jubjub::Jid.new( 'room@conference.theo-template.local/nick' ), @config )
        @room.should be_a_kind_of Jubjub::Muc
        @room.jid.should == Jubjub::Jid.new( 'room@conference.theo-template.local' )
      end
      
      after do
        @room.destroy
      end
      
    end
    
    describe "configuration" do
      
      use_vcr_cassette 'muc configuration', :record => :new_episodes
      
      it "return a Jubjub::MucConfiguration" do
        config = @connection.muc.configuration( Jubjub::Jid.new 'room@conference.theo-template.local/nick' )
        
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
        
        config.should == Jubjub::MucConfiguration.new(expected_config)
      end
      
    end
    
    describe "list" do
      
      use_vcr_cassette 'muc list', :record => :new_episodes
      
      before do
        @connection.muc.create Jubjub::Jid.new( 'test_1@conference.theo-template.local/nick' )
        @connection.muc.create Jubjub::Jid.new( 'test_2@conference.theo-template.local/nick' )
      end
      
      it "return an array of Jubjub::Muc" do
        list = @connection.muc.list( Jubjub::Jid.new 'conference.theo-template.local' )
        list.should be_a_kind_of Array
        
        list.size.should eql(2)
        list[0].should be_a_kind_of Jubjub::Muc
        list[0].jid.should == Jubjub::Jid.new( 'test_1@conference.theo-template.local' )
        list[1].should be_a_kind_of Jubjub::Muc
        list[1].jid.should == Jubjub::Jid.new( 'test_2@conference.theo-template.local' )
      end
      
    end
    
    describe "destroy" do
      
      use_vcr_cassette 'muc destroy', :record => :new_episodes
      
      before do
        @jid      = Jubjub::Jid.new 'extra@conference.theo-template.local'
        @full_jid = Jubjub::Jid.new 'extra@conference.theo-template.local/nick'
        @connection.muc.create @full_jid
      end
      
      it "return true" do
        @connection.muc.destroy( @jid ).should be_true
      end
      
    end
    
  end
  
end