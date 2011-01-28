require 'spec_helper'

describe Jubjub::Connection::XmppGateway do
  
  before do
    @connection = Jubjub::Connection::XmppGateway.new('theozaurus@theo-template.local','secret', {:host => '127.0.0.1', :port => '8000'})
  end
  
  describe "muc" do
    
    describe "create" do
      
      use_vcr_cassette 'muc create', :record => :new_episodes
      
      it "return a Jubjub::Muc" do
        room = @connection.muc.create( Jubjub::Jid.new 'room@conference.theo-template.local/nick' )
        room.should be_a_kind_of Jubjub::Muc
        room.jid.should == Jubjub::Jid.new( 'room@conference.theo-template.local' )
      end
      
    end
    
    describe "list" do
      
      use_vcr_cassette 'muc list', :record => :new_episodes
      
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