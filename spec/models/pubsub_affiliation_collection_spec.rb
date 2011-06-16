require 'spec_helper'

describe Jubjub::Pubsub::AffiliationCollection do
  
  describe "that are proxied like" do
    
    before do
      @mock_connection = mock
      @affiliations = [
        Jubjub::Pubsub::Affiliation.new('theozaurus@foo.com', 'owner', @mock_connection),
        Jubjub::Pubsub::Affiliation.new('dragonzaurus@foo.com', 'publisher', @mock_connection)        
      ]
      @mock_connection.stub_chain( :pubsub, :retrieve_affiliations ).and_return(@affiliations)
    end
    
    describe "inspect" do

      it "should show the list of affiliations, not Pubsub::AffiliationCollection" do
        Jubjub::Pubsub::AffiliationCollection.new('pubsub.foo.com', 'node_1', @mock_connection).inspect.should eql(@affiliations.inspect)
      end

    end

    describe "map" do

      it "should pass the block to the rooms" do
        c = Jubjub::Pubsub::AffiliationCollection.new('pubsub.foo.com', 'node_1', @mock_connection)
        c.map{|r| r.affiliation.to_s }.should eql(['owner', 'publisher'])
      end

    end
    
  end
  
  describe "instance method" do
    
    describe "jid" do
      it "should return the jid" do
        Jubjub::Pubsub::AffiliationCollection.new("pubsub.foo.com", "node", mock).jid.should == Jubjub::Jid.new("pubsub.foo.com")
      end
    end
    
    describe "node" do
      it "should return the node" do
        Jubjub::Pubsub::AffiliationCollection.new("pubsub.foo.com", "node", mock).node.should == 'node'
      end
    end
    
    describe "[]" do
      before do
        @mock_connection = mock
        @nodes = [
          Jubjub::Pubsub::Affiliation.new('theozaurus@foo.com', 'owner', @mock_connection),
          Jubjub::Pubsub::Affiliation.new('dragonzaurus@foo.com', 'member', @mock_connection)        
        ]
        @mock_connection.stub_chain( :pubsub, :retrieve_affiliations ).and_return(@nodes)
      end
      
      subject { Jubjub::Pubsub::AffiliationCollection.new "pubsub.foo.com", "node_1", @mock_connection }
      
      it "should work like a normal array when passed a Fixnum" do
        subject[1].should == @nodes[1]
      end
      
      it "should search by jid if a String" do
        subject["theozaurus@foo.com"].should == @nodes[0]
      end

      it "should return affiliation of 'none' if not found when searching by String" do
        subject['blogozaurus@foo.com'].should == Jubjub::Pubsub::Affiliation.new('blogozaurus@foo.com', 'none', @mock_connection)
      end
      
      it "should search by Jid if Jubjub::Jid" do
        subject[Jubjub::Jid.new 'dragonzaurus@foo.com'].should == @nodes[1]
      end
      
      it "should return afiliation of 'none' if not found when searching by Jubjub::Jid" do
        subject[Jubjub::Jid.new 'blogozaurus@foo.com'].should == Jubjub::Pubsub::Affiliation.new('blogozaurus@foo.com', 'none', @mock_connection)
        
      end
    end
    
  end
  
end