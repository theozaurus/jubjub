require 'spec_helper'

describe Jubjub::Pubsub::Collection do

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

      it "should show the list of rooms, not Muc::Collection" do
        Jubjub::Pubsub::Collection.new('pubsub.foo.com', @mock_connection).inspect.should eql(@nodes.inspect)
      end

    end

    describe "map" do

      it "should pass the block to the rooms" do
        c = Jubjub::Pubsub::Collection.new('pubsub.foo.com', @mock_connection)
        c.map{|r| r.node.to_s }.should eql(['node_1', 'node_2'])
      end

    end

  end

  describe "instance method" do

    describe "jid" do
      it "should return the jid" do
        p = Jubjub::Pubsub::Collection.new "pubsub.foo.com", mock
        p.jid.should == Jubjub::Jid.new('pubsub.foo.com')
      end
    end

    describe "subscribe" do
      it "should call pubsub.subscribe on connection" do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :subscribe
        @mock_connection.pubsub.should_receive(:subscribe).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node' )

        p = Jubjub::Pubsub::Collection.new "pubsub.foo.com", @mock_connection
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

        p = Jubjub::Pubsub::Collection.new "pubsub.foo.com", @mock_connection
        p.unsubscribe "node"
      end

      it "with subid should call pubsub.unsubscribe on connection" do
        @mock_connection.pubsub.should_receive(:unsubscribe).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node', '123' )

        p = Jubjub::Pubsub::Collection.new "pubsub.foo.com", @mock_connection
        p.unsubscribe "node", "123"
      end
    end

    describe "create" do
      before do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :create
      end

      it "should call pubsub.create on connection" do
        @mock_connection.pubsub.should_receive(:create).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node', nil )

        p = Jubjub::Pubsub::Collection.new "pubsub.foo.com", @mock_connection
        p.create "node"
      end

      it "should yield a Pubsub::Configuration if a block is given" do
        @config = Jubjub::Pubsub::Configuration.new( "foo" => { :type => "boolean", :value => "1", :label => "Foo" } )

        @mock_connection.pubsub.should_receive( :default_configuration ).with( Jubjub::Jid.new( 'pubsub.foo.com' ) ).and_return( @config )
        @mock_connection.pubsub.should_receive( :create ).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node', @config )

        Jubjub::Pubsub::Collection.new( "pubsub.foo.com", @mock_connection ).create( 'node' ){|config|
          config.should == @config
        }
      end

      it "should use supplied configuration if available and no block is given" do
        @config = Jubjub::Pubsub::Configuration.new( "foo" => { :type => "boolean", :value => "1", :label => "Foo" } )

        @mock_connection.pubsub.should_receive( :create ).with( Jubjub::Jid.new( 'pubsub.foo.com' ), 'node', @config )

        Jubjub::Pubsub::Collection.new( "pubsub.foo.com", @mock_connection ).create( 'node', @config)
      end
    end

    describe "[]" do
      before do
        @mock_connection = mock
        @nodes = [
          Jubjub::Pubsub.new('pubsub.foo.com', 'node_1', @mock_connection),
          Jubjub::Pubsub.new('pubsub.foo.com', 'node_2', @mock_connection)
        ]
        @mock_connection.stub_chain( :pubsub, :list ).and_return(@nodes)
      end

      subject { Jubjub::Pubsub::Collection.new "pubsub.foo.com", @mock_connection }

      it "should work like a normal array when passed a Fixnum" do
        subject[1].should == @nodes[1]
      end

      describe "searching by node if a String" do

        it "should return cached result if it has already searched" do
          # Trigger lookup
          @mock_connection.pubsub.should_receive(:list)
          subject.first
          subject["node_1"].should equal @nodes[0]
        end

        it "should return default result if it has already searched and does not exist" do
          # Trigger lookup
          @mock_connection.pubsub.should_receive(:list)
          subject.first
          subject['made-up'].should == Jubjub::Pubsub.new( 'pubsub.foo.com', 'made-up', @mock_connection )
        end

        it "should return default result if it has not already searched" do
          @mock_connection.pubsub.should_not_receive(:list)
          subject['node_1'].should_not equal @nodes[0]
          subject['node_1'].should == Jubjub::Pubsub.new( 'pubsub.foo.com', 'node_1', @mock_connection )
        end

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

        p = Jubjub::Pubsub::Collection.new "pubsub.foo.com", @mock_connection
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

        p = Jubjub::Pubsub::Collection.new "pubsub.foo.com", @mock_connection
        p.destroy "node"
      end
    end

    describe "purge" do

      before do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :purge
      end

      it "should call pubsub.purge on connection" do
        @mock_connection.pubsub.should_receive(:purge).with(
          Jubjub::Jid.new('pubsub.foo.com'),
          'node'
        )

        m = Jubjub::Pubsub::Collection.new 'pubsub.foo.com', @mock_connection
        m.purge('node')
      end

    end

  end

end
