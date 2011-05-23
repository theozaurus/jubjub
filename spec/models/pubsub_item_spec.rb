require 'spec_helper'

describe Jubjub::PubsubItem do
  
  def pubsub_item_factory(override = {})
    options = {
      :jid        => Jubjub::Jid.new("pubsub.foo.com"),
      :node       => 'node',
      :item_id    => '123',
      :data       => 'foo',
      :connection => "SHHHH CONNECTION OBJECT"
    }.merge( override )
    
    Jubjub::PubsubItem.new(
      options[:jid],
      options[:node],
      options[:item_id],
      options[:data],
      options[:connection]
    )
  end
  
  describe "instance method" do
    
    describe "jid" do
      it "should return the jid" do
        p = pubsub_item_factory :jid => 'foo.com'
        p.jid.should == Jubjub::Jid.new('foo.com')
      end
    end
    
    describe "node" do
      it "should return the node" do
        p = pubsub_item_factory :node => 'node_1'
        p.node.should == 'node_1'
      end
    end
    
    describe "data" do
      it "should return the data" do
        p = pubsub_item_factory :data => 'hello'
        p.data.should == 'hello'
      end
    end
    
    describe "item_id" do
      it "should return the item_id" do
        p = pubsub_item_factory :item_id => 'as12'
        p.item_id.should == 'as12'
      end
    end
    
    describe "retract" do
      it "should call pubsub.retract on connection" do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :retract
        @mock_connection.pubsub.should_receive(:retract).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node', '123' )
    
        p = pubsub_item_factory :jid => 'pubsub.foo.com', :node => 'node', :item_id => '123', :connection => @mock_connection
        p.retract
      end
    end
    
  end
  
end