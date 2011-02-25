require 'spec_helper'

describe Jubjub::PubsubCollection do
  
  describe "that are proxied like" do
    
    before do
      @mock_connection = mock
      @nodes = [
        Jubjub::Pubsub.new('pubsub.foo.com', 'node_1', @mock_connection),
        Jubjub::Pubsub.new('pubsub.foo.com', 'node_2', @mock_connection)        
      ]
      @mock_connection.stub_chain( :pubsub, :list ).and_return(@nodes)
    end
    
    describe "inspect" do

      it "should show the list of rooms, not MucCollection" do
        Jubjub::PubsubCollection.new('pubsub.foo.com', @mock_connection).inspect.should eql(@nodes.inspect)
      end

    end

    describe "map" do

      it "should pass the block to the rooms" do
        c = Jubjub::PubsubCollection.new('pubsub.foo.com', @mock_connection)
        c.map{|r| r.node.to_s }.should eql(['node_1', 'node_2'])
      end

    end
    
  end
  
  describe "instance method" do
    
    describe "jid" do
      it "should return the jid" do
        p = Jubjub::PubsubCollection.new "pubsub.foo.com", mock
        p.jid.should == Jubjub::Jid.new('pubsub.foo.com')
      end
    end
         
    describe "subscribe" do
      it "should call pubsub.subscribe on connection" do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :subscribe
        @mock_connection.pubsub.should_receive(:subscribe).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node' )
    
        p = Jubjub::PubsubCollection.new "pubsub.foo.com", @mock_connection
        p.subscribe "node"       
      end
    end
    
    describe "unsubscribe" do
      before do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :unsubscribe
      end
      
      it "without subid should call pubsub.unsubscribe on connection" do
        @mock_connection.pubsub.should_receive(:unsubscribe).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node', nil )

        p = Jubjub::PubsubCollection.new "pubsub.foo.com", @mock_connection
        p.unsubscribe "node"       
      end
      
      it "with subid should call pubsub.unsubscribe on connection" do
        @mock_connection.pubsub.should_receive(:unsubscribe).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node', '123' )

        p = Jubjub::PubsubCollection.new "pubsub.foo.com", @mock_connection
        p.unsubscribe "node", "123"
      end
    end
    
    describe "create" do
      it "should call pubsub.create on connection" do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :create
        
        @mock_connection.pubsub.should_receive(:create).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node' )        
        
        p = Jubjub::PubsubCollection.new "pubsub.foo.com", @mock_connection
        p.create "node"
      end
    end
    
    describe "destroy" do
      it "with redirect should call pubsub.destroy on connection" do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :destroy
        
        @mock_connection.pubsub.should_receive(:destroy).with( 
          Jubjub::Jid.new('pubsub.foo.com'),
          'node',
          Jubjub::Jid.new('pubsub.new.com'),
          'node_2'
        )
        
        p = Jubjub::PubsubCollection.new "pubsub.foo.com", @mock_connection
        p.destroy "node", "pubsub.new.com", "node_2"
      end
      
      it "without redirect should call pubsub.destroy on connection" do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :destroy
        
        @mock_connection.pubsub.should_receive(:destroy).with( 
          Jubjub::Jid.new('pubsub.foo.com'),
          'node',
          nil,
          nil
        )
        
        p = Jubjub::PubsubCollection.new "pubsub.foo.com", @mock_connection
        p.destroy "node"
      end
    end
    
  end
  
end