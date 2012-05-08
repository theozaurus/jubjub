require 'spec_helper'

describe Jubjub::Pubsub::SubscriptionCollection do

  describe "that are proxied like" do

    before do
      @mock_connection = mock
      @subscriptions = [
        Jubjub::Pubsub::Subscription.new('pubsub.foo.com', 'node', 'theozaurus@foo.com', '1', 'subscriber', @mock_connection),
        Jubjub::Pubsub::Subscription.new('pubsub.foo.com', 'node', 'dragonzaurus@foo.com', '2', 'subscriber', @mock_connection)
      ]
      @mock_connection.stub_chain( :pubsub, :subscriptions ).and_return(@subscriptions)
    end

    describe "inspect" do

      it "should show the list of subscriptions, not Pubsub::SubscriptionCollection" do
        Jubjub::Pubsub::SubscriptionCollection.new('pubsub.foo.com', 'node_1', @mock_connection).inspect.should eql(@subscriptions.inspect)
      end

    end

    describe "map" do

      it "should pass the block to the rooms" do
        c = Jubjub::Pubsub::SubscriptionCollection.new('pubsub.foo.com', 'node_1', @mock_connection)
        c.map{|r| r.subid.to_s }.should eql(['1', '2'])
      end

    end

  end

  describe "instance method" do

    describe "jid" do
      it "should return the jid" do
        Jubjub::Pubsub::SubscriptionCollection.new("pubsub.foo.com", "node", mock).jid.should == Jubjub::Jid.new("pubsub.foo.com")
      end
    end

    describe "node" do
      it "should return the node" do
        Jubjub::Pubsub::SubscriptionCollection.new("pubsub.foo.com", "node", mock).node.should == 'node'
      end
    end

    describe "[]" do
      before do
        @mock_connection = mock
        @nodes = [
          Jubjub::Pubsub::Subscription.new('pubsub.foo.com', 'node_1', 'theozaurus@foo.com', '1', 'subscribed', @mock_connection),
          Jubjub::Pubsub::Subscription.new('pubsub.foo.com', 'node_1', 'dragonzaurus@foo.com', '2', 'subscribed', @mock_connection)
        ]
        @mock_connection.stub_chain( :pubsub, :subscriptions ).and_return(@nodes)
      end

      subject { Jubjub::Pubsub::SubscriptionCollection.new "pubsub.foo.com", "node_1", @mock_connection }

      it "should work like a normal array when passed a Fixnum" do
        subject[1].should == @nodes[1]
      end

      describe "searching by node if a String" do

        it "should return cached result if it has already searched" do
          # Trigger lookup
          @mock_connection.pubsub.should_receive(:subscriptions)
          subject.first
          subject["theozaurus@foo.com"].should equal @nodes[0]
        end

        it "should return default result if it has already searched and does not exist" do
          # Trigger lookup
          @mock_connection.pubsub.should_receive(:subscriptions)
          subject.first
          subject['blogozaurus@foo.com'].should ==
            Jubjub::Pubsub::Subscription.new('pubsub.foo.com', 'node_1', 'blogozaurus@foo.com', nil, 'unsubscribed', @mock_connection)
        end

        it "should return default result if it has not already searched" do
          @mock_connection.pubsub.should_not_receive(:subscriptions)
          subject['theozaurus@foo.com'].should_not equal @nodes[0]
          subject['theozaurus@foo.com'].should ==
            Jubjub::Pubsub::Subscription.new('pubsub.foo.com', 'node_1', 'theozaurus@foo.com', nil, 'unsubscribed', @mock_connection)
        end

      end

      describe "searching by jid if a Jubjub::Jid" do

        it "should return cached result if it has already searched" do
          # Trigger lookup
          @mock_connection.pubsub.should_receive(:subscriptions)
          subject.first
          subject[Jubjub::Jid.new "theozaurus@foo.com"].should equal @nodes[0]
        end

        it "should return default result if it has already searched and does not exist" do
          # Trigger lookup
          @mock_connection.pubsub.should_receive(:subscriptions)
          subject.first
          subject[Jubjub::Jid.new 'blogozaurus@foo.com'].should ==
            Jubjub::Pubsub::Subscription.new('pubsub.foo.com', 'node_1', 'blogozaurus@foo.com', nil, 'unsubscribed', @mock_connection)
        end

        it "should return default result if it has not already searched" do
          @mock_connection.pubsub.should_not_receive(:subscriptions)
          subject[Jubjub::Jid.new 'theozaurus@foo.com'].should_not equal @nodes[0]
          subject[Jubjub::Jid.new 'theozaurus@foo.com'].should ==
            Jubjub::Pubsub::Subscription.new('pubsub.foo.com', 'node_1', 'theozaurus@foo.com', nil, 'unsubscribed', @mock_connection)
        end

      end

    end

  end

end
