require 'spec_helper'

describe Jubjub::Pubsub::AffiliationCollection do
  
  describe "that are proxied like" do
    
    before do
      @mock_connection = mock
      @affiliations = [
        Jubjub::Pubsub::Affiliation.new('pubsub.foo.com', 'node', 'theozaurus@foo.com', 'owner', @mock_connection),
        Jubjub::Pubsub::Affiliation.new('pubsub.foo.com', 'node', 'dragonzaurus@foo.com', 'publisher', @mock_connection)        
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
          Jubjub::Pubsub::Affiliation.new('pubsub.foo.com', 'node_1', 'theozaurus@foo.com', 'owner', @mock_connection),
          Jubjub::Pubsub::Affiliation.new('pubsub.foo.com', 'node_1', 'dragonzaurus@foo.com', 'member', @mock_connection)        
        ]
        @mock_connection.stub_chain( :pubsub, :retrieve_affiliations ).and_return(@nodes)
      end
      
      subject { Jubjub::Pubsub::AffiliationCollection.new "pubsub.foo.com", "node_1", @mock_connection }
      
      it "should work like a normal array when passed a Fixnum" do
        subject[1].should == @nodes[1]
      end
      
      describe "searching by node if a String" do
      
        it "should return cached result if it has already searched" do
          # Trigger lookup
          @mock_connection.pubsub.should_receive(:retrieve_affiliations)
          subject.first
          subject["theozaurus@foo.com"].should equal @nodes[0]
        end
      
        it "should return default result if it has already searched and does not exist" do
          # Trigger lookup
          @mock_connection.pubsub.should_receive(:retrieve_affiliations)
          subject.first
          subject['blogozaurus@foo.com'].should == 
            Jubjub::Pubsub::Affiliation.new('pubsub.foo.com', 'node_1', 'blogozaurus@foo.com', 'none', @mock_connection)
        end
      
        it "should return default result if it has not already searched" do
          @mock_connection.pubsub.should_not_receive(:retrieve_affiliations)
          subject['theozaurus@foo.com'].should_not equal @nodes[0]
          subject['theozaurus@foo.com'].should == 
            Jubjub::Pubsub::Affiliation.new('pubsub.foo.com', 'node_1', 'theozaurus@foo.com', 'none', @mock_connection)
        end
        
      end
      
      describe "searching by jid if a Jubjub::Jid" do
      
        it "should return cached result if it has already searched" do
          # Trigger lookup
          @mock_connection.pubsub.should_receive(:retrieve_affiliations)
          subject.first
          subject[Jubjub::Jid.new "theozaurus@foo.com"].should equal @nodes[0]
        end
      
        it "should return default result if it has already searched and does not exist" do
          # Trigger lookup
          @mock_connection.pubsub.should_receive(:retrieve_affiliations)
          subject.first
          subject[Jubjub::Jid.new 'blogozaurus@foo.com'].should == 
            Jubjub::Pubsub::Affiliation.new('pubsub.foo.com', 'node_1', 'blogozaurus@foo.com', 'none', @mock_connection)
        end
      
        it "should return default result if it has not already searched" do
          @mock_connection.pubsub.should_not_receive(:retrieve_affiliations)
          subject[Jubjub::Jid.new 'theozaurus@foo.com'].should_not equal @nodes[0]
          subject[Jubjub::Jid.new 'theozaurus@foo.com'].should == 
            Jubjub::Pubsub::Affiliation.new('pubsub.foo.com', 'node_1', 'theozaurus@foo.com', 'none', @mock_connection)
        end
        
      end
      
    end
    
  end
  
end