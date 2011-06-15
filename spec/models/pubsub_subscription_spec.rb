require 'spec_helper'

describe Jubjub::Pubsub::Subscription do
  
  def pubsub_subscription_factory(override = {})
    options = {
      :jid          => Jubjub::Jid.new("pubsub.foo.com"),
      :node         => 'node',
      :subscriber   => Jubjub::Jid.new("theo@foo.com"),
      :subid        => nil,
      :subscription => 'subscribed',
      :connection   => "SHHHH CONNECTION OBJECT"
    }.merge( override )
    
    Jubjub::Pubsub::Subscription.new(
      options[:jid],
      options[:node],
      options[:subscriber],
      options[:subid],
      options[:subscription],
      options[:connection]
    )
  end
  
  describe "instance method" do
    
    describe "inspect" do
      
      it "should not show connection information" do
        p = pubsub_subscription_factory :connection => 'SHHHH CONNECTION OBJECT'
        p.inspect.should_not match 'SHHHH CONNECTION OBJECT'
      end
      
      it "should show string version of jid" do
        p = pubsub_subscription_factory :jid => Jubjub::Jid.new("pubsub.foo.com")
        p.inspect.should match '@jid="pubsub.foo.com"'
      end
      
      it "should show node" do
        p = pubsub_subscription_factory :node => "node"
        p.inspect.should match '@node="node"'
      end
      
      it "should show string version of subscriber" do
        p = pubsub_subscription_factory :subscriber => Jubjub::Jid.new("theo@foo.com")
        p.inspect.should match '@subscriber="theo@foo.com"'
      end
      
      it "should show subid" do
        p = pubsub_subscription_factory :subid => nil
        p.inspect.should match '@subid=nil'
        
        p = pubsub_subscription_factory :subid => "wibble"
        p.inspect.should match '@subid="wibble"'
      end
      
      it "should show subscription" do
        p = pubsub_subscription_factory :subscription => nil
        p.inspect.should match '@subscription=nil'
        
        p = pubsub_subscription_factory :subscription => 'subscribed'
        p.inspect.should match '@subscription="subscribed"'
      end
      
    end
    
    describe "jid" do
      it "should return the jid" do
        p = pubsub_subscription_factory :jid => 'foo.com'
        p.jid.should == Jubjub::Jid.new('foo.com')
      end
    end
    
    describe "node" do
      it "should return the node" do
        p = pubsub_subscription_factory :node => 'node_1'
        p.node.should == 'node_1'
      end
    end
    
    describe "subscriber" do
      it "should return the subscriber jid" do
        p = pubsub_subscription_factory :subscriber => 'theo@foo.com'
        p.subscriber.should == Jubjub::Jid.new('theo@foo.com')
      end
    end
    
    describe "subid" do
      it "should return the subid" do
        p = pubsub_subscription_factory :subid => 'as12'
        p.subid.should == 'as12'
      end
    end
    
    describe "subscription" do
      it "should return the subscription" do
        p = pubsub_subscription_factory :subscription => '32'
        p.subscription.should == '32'
      end
    end
         
    describe "unsubscribe" do
      it "should call pubsub.unsubscribe on connection" do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :unsubscribe
        @mock_connection.pubsub.should_receive(:unsubscribe).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node', '123' )
    
        p = pubsub_subscription_factory :jid => 'pubsub.foo.com', :node => 'node', :subid => '123', :connection => @mock_connection
        p.unsubscribe
      end
    end
    
  end
  
end