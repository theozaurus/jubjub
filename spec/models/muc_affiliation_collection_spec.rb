require 'spec_helper'

describe Jubjub::Muc::AffiliationCollection do
  
  describe "that are proxied like" do
    
    before do
      @mock_connection = mock
      @affiliations = [
        muc_affiliation_factory( :affiliation => 'owner' ),
        muc_affiliation_factory( :affiliation => 'admin' )
      ]
      # Hack to get around the fact that [] calls retrieve_affiliations several times with different affiliations
      @mock_connection.stub_chain( :muc, :retrieve_affiliations ).with{|jid,affiliation| affiliation == "owner" }.and_return(@affiliations)
      @mock_connection.stub_chain( :muc, :retrieve_affiliations ).with{|jid,affiliation| affiliation != "owner" }.and_return([])
    end
    
    describe "inspect" do

      it "should show the list of affiliations, not Muc::AffiliationCollection" do
        Jubjub::Muc::AffiliationCollection.new('conference.foo.com', @mock_connection).inspect.should eql(@affiliations.inspect)
      end

    end

    describe "map" do

      it "should pass the block to the rooms" do
        c = Jubjub::Muc::AffiliationCollection.new('conference.foo.com', @mock_connection)
        c.map{|r| r.affiliation.to_s }.should eql(['owner', 'admin'])
      end

    end
    
  end
  
  describe "instance method" do
    
    describe "jid" do
      it "should return the jid" do
        Jubjub::Muc::AffiliationCollection.new("conference.foo.com", mock).jid.should == Jubjub::Jid.new("conference.foo.com")
      end
    end
    
    describe "[]" do
      before do
        @mock_connection = mock
        @affiliations = [
          muc_affiliation_factory( :jid => 'theozaurus@foo.com',   :affiliation => 'owner' ),
          muc_affiliation_factory( :jid => 'dragonzaurus@foo.com', :affiliation => 'member' )
        ]
        # Hack to get around the fact that [] calls retrieve_affiliations several times with different affiliations
        @mock_connection.stub_chain( :muc, :retrieve_affiliations ).with{|jid,affiliation| affiliation == "owner" }.and_return(@affiliations)
        @mock_connection.stub_chain( :muc, :retrieve_affiliations ).with{|jid,affiliation| affiliation != "owner" }.and_return([])
      end
      
      subject { Jubjub::Muc::AffiliationCollection.new "conference.foo.com", @mock_connection }
      
      it "should call retrieve_affiliations with owner, outcast, member, admin" do
        muc_mock = mock
        @mock_connection.stub(:muc).and_return(muc_mock)
        muc_mock.should_receive(:retrieve_affiliations).with(subject.jid, 'owner')
        muc_mock.should_receive(:retrieve_affiliations).with(subject.jid, 'outcast')
        muc_mock.should_receive(:retrieve_affiliations).with(subject.jid, 'member')
        muc_mock.should_receive(:retrieve_affiliations).with(subject.jid, 'admin')
                
        subject[0]
      end
      
      it "should work like a normal array when passed a Fixnum" do
        subject[1].should == @affiliations[1]
      end
      
      it "should search by jid if a String" do
        subject["theozaurus@foo.com"].should == @affiliations[0]
      end

      it "should return affiliation of 'none', and role and nick as nil if not found when searching by String" do
        subject['blogozaurus@foo.com'].should ==
          muc_affiliation_factory( :muc_jid => 'conference.foo.com',
                                   :jid => 'blogozaurus@foo.com',
                                   :affiliation => 'none',
                                   :role => nil,
                                   :nick => nil )
      end
      
      it "should search by Jid if Jubjub::Jid" do
        subject[Jubjub::Jid.new 'dragonzaurus@foo.com'].should == @affiliations[1]
      end
      
      it "should return afiliation of 'none', and role and nick as nil if not found when searching by Jubjub::Jid" do
        subject[Jubjub::Jid.new 'blogozaurus@foo.com'].should ==
          muc_affiliation_factory( :muc_jid => 'conference.foo.com',
                                   :jid => 'blogozaurus@foo.com',
                                   :affiliation => 'none',
                                   :role => nil,
                                   :nick => nil )
      end
    end
    
  end
  
end