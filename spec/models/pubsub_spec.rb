require 'spec_helper'

describe Jubjub::Pubsub do
  
  describe "instance method" do
    
    describe "inspect" do
      
      it "should not show connection information" do
        m = Jubjub::Pubsub.new(Jubjub::Jid.new("pubsub.foo.com"),'node',"SHHHH CONNECTION OBJECT")
        m.inspect.should_not match 'SHHHH CONNECTION OBJECT'
      end
      
      it "should show string version of jid" do
        m = Jubjub::Pubsub.new(Jubjub::Jid.new("pubsub.foo.com"),'node',mock)
        m.inspect.should match '@jid="pubsub.foo.com"'
      end
      
      it "should show node" do
        m = Jubjub::Pubsub.new(Jubjub::Jid.new("pubsub.foo.com"),nil,mock)
        m.inspect.should match '@node=nil'
        
        m = Jubjub::Pubsub.new(Jubjub::Jid.new("pubsub.foo.com"),'node',mock)
        m.inspect.should match '@node="node"'
      end
      
    end
    
    describe "jid" do
      it "should return the jid" do
        Jubjub::Pubsub.new('pubsub.foo.com','node', mock).jid.should == Jubjub::Jid.new('pubsub.foo.com')
      end
    end
    
    describe "node" do
      it "should return the node" do
        Jubjub::Pubsub.new('pubsub.foo.com','node', mock).node.should == 'node'
      end
    end
    
    describe "subscribe" do
      it "should call pubsub.subscribe on connection" do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :subscribe
        @mock_connection.pubsub.should_receive(:subscribe).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node' )

        m = Jubjub::Pubsub.new 'pubsub.foo.com', 'node', @mock_connection
        m.subscribe
      end
    end
    
    describe "unsubscribe" do
      
      before do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :unsubscribe
      end
      
      describe "with subid" do
        it "should call pubsub.unsubscribe on connection" do
          @mock_connection.pubsub.should_receive(:unsubscribe).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node', 'wibble' )

          m = Jubjub::Pubsub.new 'pubsub.foo.com', 'node', @mock_connection
          m.unsubscribe 'wibble'
        end
      end
      
      describe "without subid" do
        it "should call pubsub.unsubscribe on connection" do
          @mock_connection.pubsub.should_receive(:unsubscribe).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node', nil )

          m = Jubjub::Pubsub.new 'pubsub.foo.com', 'node', @mock_connection
          m.unsubscribe
        end
      end
      
    end
    
    describe "destroy" do
      
      before do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :destroy
      end
      
      it "without redirect should call pubsub.destroy on connection" do
        @mock_connection.pubsub.should_receive(:destroy).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node', nil, nil )

        m = Jubjub::Pubsub.new 'pubsub.foo.com', 'node', @mock_connection
        m.destroy
      end
      
      it "with redirect should call pubsub.destroy on connection" do
        @mock_connection.pubsub.should_receive(:destroy).with( 
          Jubjub::Jid.new('pubsub.foo.com'),
          'node',
          Jubjub::Jid.new('pubsub.new.com'),
          'node_2' )

        m = Jubjub::Pubsub.new 'pubsub.foo.com', 'node', @mock_connection
        m.destroy 'pubsub.new.com', 'node_2'
      end
      
    end
    
  end
  
end