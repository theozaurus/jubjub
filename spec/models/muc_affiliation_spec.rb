require 'spec_helper'

describe Jubjub::Muc::Affiliation do

  describe "instance method" do
    
    describe "muc_jid" do
      it "should return the muc_jid" do
        p = muc_affiliation_factory :muc_jid => 'muc.foo.com'
        p.muc_jid.should == Jubjub::Jid.new('muc.foo.com')
      end
    end
    
    describe "jid" do
      it "should return the jid" do
        p = muc_affiliation_factory :jid => 'bob@foo.com'
        p.jid.should == Jubjub::Jid.new('bob@foo.com')
      end
    end
    
    describe "nick" do
      it "should return the nick" do
        p = muc_affiliation_factory :nick => 'bob'
        p.nick.should == 'bob'
      end
    end
    
    describe "role" do
      it "should return the role" do
        p = muc_affiliation_factory :role => 'moderator'
        p.role.should == 'moderator'
      end
    end
    
    describe "affiliation" do
      it "should return the affiliation" do
        p = muc_affiliation_factory :affiliation => 'admin'
        p.affiliation.should == 'admin'
      end
    end
    
    describe "owner?" do
      it "should return true when affiliation is 'owner'" do
        muc_affiliation_factory( :affiliation => 'owner' ).owner?.should equal(true)
      end
      
      it "should return false when affiliation is not 'owner'" do
        muc_affiliation_factory( :affiliation => 'admin' ).owner?.should equal(false)
      end
    end
    
    describe "admin?" do
      it "should return true when affiliation is 'admin'" do
        muc_affiliation_factory( :affiliation => 'admin' ).admin?.should equal(true)
      end
      
      it "should return false when affiliation is not 'admin'" do
        muc_affiliation_factory( :affiliation => 'owner' ).admin?.should equal(false)
      end
    end
    
    describe "member?" do
      it "should return true when affiliation is 'member'" do
        muc_affiliation_factory( :affiliation => 'member' ).member?.should equal(true)
      end
      
      it "should return false when affiliation is not 'member'" do
        muc_affiliation_factory( :affiliation => 'publisher' ).member?.should equal(false)
      end
    end
    
    describe "none?" do
      it "should return true when affiliation is 'none'" do
        muc_affiliation_factory( :affiliation => 'none' ).none?.should equal(true)
      end
      
      it "should return false when affiliation is not 'none'" do
        muc_affiliation_factory( :affiliation => 'publisher' ).none?.should equal(false)
      end
    end
    
    describe "outcast?" do
      it "should return true when affiliation is 'outcast'" do
        muc_affiliation_factory( :affiliation => 'outcast' ).outcast?.should equal(true)
      end
      
      it "should return false when affiliation is not 'outcast'" do
        muc_affiliation_factory( :affiliation => 'publisher' ).outcast?.should equal(false)
      end
    end
    
    describe "set" do
      it "should redirect call to muc.modify_affiliations" do
        @mock_connection = mock
        @mock_connection.stub_chain :muc, :modify_affiliations
        
        affiliation = muc_affiliation_factory :connection => @mock_connection
        
        @mock_connection.muc.should_receive(:modify_affiliations).with( affiliation.muc_jid, affiliation )
        
        affiliation.set 'admin'
      end

      describe "when succesful" do
        before do
          @mock_connection = mock
          @mock_connection.stub_chain( :muc, :modify_affiliations ).and_return( true )
        end
        
        it "should return true" do
          @affiliation = muc_affiliation_factory :connection => @mock_connection
          @affiliation.set( 'admin' ).should equal( true )
        end
        
        it "should have affiliaton set to new value" do
          @affiliation = muc_affiliation_factory :connection => @mock_connection, :affiliation => 'owner'
          @affiliation.set 'admin'
          @affiliation.affiliation.should == 'admin'
        end
      end
      
      describe "when unsuccesful" do
        before do
          @mock_connection = mock
          @mock_connection.stub_chain( :muc, :modify_affiliations ).and_return( false )
        end
        
        it "should return false" do
          @affiliation = muc_affiliation_factory :connection => @mock_connection
          @affiliation.set( 'admin' ).should equal( false )
        end
        
        it "should have affiliaton set to original value" do
          @affiliation = muc_affiliation_factory :connection => @mock_connection, :affiliation => 'owner'
          @affiliation.set 'admin'
          @affiliation.affiliation.should == 'owner'
        end
      end
    end
    
    describe "set_owner" do
      it "should redirect call to set" do
        affiliation = muc_affiliation_factory
        affiliation.should_receive(:set).with('owner').and_return( 'from-set' )
        
        affiliation.set_owner.should == 'from-set'
      end
    end
    
    describe "set_admin" do
      it "should redirect call to set" do
        affiliation = muc_affiliation_factory
        affiliation.should_receive(:set).with('admin').and_return( 'from-set' )
      
        affiliation.set_admin.should == 'from-set'
      end
    end
    
    describe "set_member" do
      it "should redirect call to set" do
        affiliation = muc_affiliation_factory
        affiliation.should_receive(:set).with('member').and_return( 'from-set' )
      
        affiliation.set_member.should == 'from-set'
      end
    end
    
    describe "set_none" do
      it "should redirect call to set" do
        affiliation = muc_affiliation_factory
        affiliation.should_receive(:set).with('none').and_return( 'from-set' )
      
        affiliation.set_none.should == 'from-set'
      end
    end
    
    describe "set_outcast" do
      it "should redirect call to set" do
        affiliation = muc_affiliation_factory
        affiliation.should_receive(:set).with('outcast').and_return( 'from-set' )
      
        affiliation.set_outcast.should == 'from-set'
      end
    end
    
    describe "==" do
      it "should match equivalent objects" do
        muc_affiliation_factory.should == muc_affiliation_factory
      end
      
      it "should not distinguish between connections" do
        muc_affiliation_factory(:connection => 'wibble').should == muc_affiliation_factory(:connection => 'wobble')
      end
      
      it "should still match no matter how jid is initialized" do
        muc_affiliation_factory(:jid => 'foo@bar.com').should == muc_affiliation_factory(:jid => Jubjub::Jid.new('foo@bar.com'))
      end
      
      it "should still match no matter how muc_jid is initialized" do
        muc_affiliation_factory(:muc_jid => 'muc.bar.com').should == 
        muc_affiliation_factory(:muc_jid => Jubjub::Jid.new('muc.bar.com'))
      end
      
      it "should not match objects with different attributes" do
        muc_affiliation_factory(:muc_jid => 'a.b.com').should_not == muc_affiliation_factory
        muc_affiliation_factory(:jid => 'a.b.com').should_not == muc_affiliation_factory
        muc_affiliation_factory(:nick => 'snicker-snack').should_not == muc_affiliation_factory
        muc_affiliation_factory(:role => 'owner').should_not == muc_affiliation_factory
        muc_affiliation_factory(:affiliation => 'member').should_not == muc_affiliation_factory
      end
    end
    
  end
  
end