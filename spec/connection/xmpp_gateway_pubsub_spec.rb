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
        
        @pubsub.should be_a_kind_of Jubjub::Pubsub
        @pubsub.jid.should == Jubjub::Jid.new('pubsub.theo-template.local')
        @pubsub.node.should == 'node_1'
      end
      
      after do
        # Clean up the node
        @connection.pubsub.destroy 'pubsub.theo-template.local', 'node_1'
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
    
    describe "list" do
      
      use_vcr_cassette 'pubsub list', :record => :new_episodes
      
      before do
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_1'
        @connection.pubsub.create 'pubsub.theo-template.local', 'node_2'
      end
      
      it "return an array of Jubjub::Muc" do
        list = @connection.pubsub.list 'pubsub.theo-template.local'
        list.should be_a_kind_of Array
        
        list.size.should eql(2)
        list[0].should be_a_kind_of Jubjub::Pubsub
        list[0].node.should == 'node_1'
        list[1].should be_a_kind_of Jubjub::Pubsub
        list[1].node.should == 'node_2'
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
      
      it "return a Jubjub::PubsubSubscription" do
        @subscription = @connection.pubsub.subscribe( 'pubsub.theo-template.local', 'node_1' )
        
        @subscription.should be_a_kind_of Jubjub::PubsubSubscription
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
    
  end
  
end