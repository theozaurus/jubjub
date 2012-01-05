require 'spec_helper'

describe Jubjub::Pubsub::Item do

  def pubsub_item_factory(override = {})
    options = {
      :jid        => Jubjub::Jid.new("pubsub.foo.com"),
      :node       => 'node',
      :item_id    => '123',
      :data       => 'foo',
      :connection => "SHHHH CONNECTION OBJECT"
    }.merge( override )

    Jubjub::Pubsub::Item.new(
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

    describe "uri" do
      it "should return the uri of the item" do
        item = pubsub_item_factory :jid => "theozaurus@foo.com", :node => "blah", :item_id => "123"
        item.uri.should == "xmpp:theozaurus@foo.com?;node=blah;item=123"
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

    describe "==" do
      it "should match equivalent objects" do
        pubsub_item_factory.should == pubsub_item_factory
      end

      it "should not distinguish between connections" do
        pubsub_item_factory(:connection => 'wibble').should == pubsub_item_factory(:connection => 'wobble')
      end

      it "should still match no matter how jid is initialized" do
        pubsub_item_factory(:jid => 'foo@bar.com').should == pubsub_item_factory(:jid => Jubjub::Jid.new('foo@bar.com'))
      end

      it "should not match objects with different attributes" do
        pubsub_item_factory(:jid     => 'a.b.com').should_not == pubsub_item_factory
        pubsub_item_factory(:node    => 'adsafsd').should_not == pubsub_item_factory
        pubsub_item_factory(:item_id => '23').should_not == pubsub_item_factory
        pubsub_item_factory(:data    => '<wibble></wibble').should_not == pubsub_item_factory
      end
    end

  end

end
