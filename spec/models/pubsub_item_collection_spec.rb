require 'spec_helper'

describe Jubjub::Pubsub::ItemCollection do

  describe "that are proxied like" do

    before do
      @mock_connection = mock
      @items = [
        Jubjub::Pubsub::Item.new('pubsub.foo.com', 'node_1', 'abc', '<foo></foo>', @mock_connection),
        Jubjub::Pubsub::Item.new('pubsub.foo.com', 'node_1', 'efg', '<bar></bar>', @mock_connection)
      ]
      @mock_connection.stub_chain( :pubsub, :retrieve_items ).and_return(@items)
    end

    describe "inspect" do

      it "should show the list of items, not Pubsub::ItemCollection" do
        Jubjub::Pubsub::ItemCollection.new('pubsub.foo.com', 'node_1', @mock_connection).inspect.should eql(@items.inspect)
      end

    end

    describe "map" do

      it "should pass the block to the items" do
        c = Jubjub::Pubsub::ItemCollection.new('pubsub.foo.com', 'node_1', @mock_connection)
        c.map{|r| r.data.to_s }.should eql(['<foo></foo>', '<bar></bar>'])
      end

    end

  end

  describe "instance method" do

    describe "jid" do
      it "should return the jid" do
        Jubjub::Pubsub::ItemCollection.new("pubsub.foo.com", "node", mock).jid.should == Jubjub::Jid.new("pubsub.foo.com")
      end
    end

    describe "node" do
      it "should return the node" do
        Jubjub::Pubsub::ItemCollection.new("pubsub.foo.com", "node", mock).node.should == 'node'
      end
    end

    describe "[]" do
      before do
        @mock_connection = mock
        @nodes = [
          Jubjub::Pubsub::Item.new('pubsub.foo.com', 'node_1', 'abc', '<foo></foo>', @mock_connection),
          Jubjub::Pubsub::Item.new('pubsub.foo.com', 'node_1', 'efg', '<bar></bar>', @mock_connection)
        ]
        @mock_connection.stub_chain( :pubsub, :retrieve_items ).and_return(@nodes)
      end

      subject { Jubjub::Pubsub::ItemCollection.new "pubsub.foo.com", "node_1", @mock_connection }

      it "should work like a normal array when passed a Fixnum" do
        subject[1].should == @nodes[1]
      end

      it "should search by node if a String" do
        subject["abc"].should == @nodes[0]
      end

      it "should return nil if nothing found" do
        subject['made-up'].should be_nil
      end
    end

  end

end
