require 'spec_helper'

describe Jubjub::Pubsub::Affiliation do
  
  def pubsub_affiliation_factory(override = {})
    options = {
      :pubsub_jid  => Jubjub::Jid.new("pubsub.foo.com"),
      :pubsub_node => "node_1",
      :jid         => Jubjub::Jid.new("theozaurus@foo.com"),
      :affiliation => 'owner',
      :connection  => "SHHHH CONNECTION OBJECT"
    }.merge( override )
    
    Jubjub::Pubsub::Affiliation.new(
      options[:pubsub_jid],
      options[:pubsub_node],
      options[:jid],
      options[:affiliation],
      options[:connection]
    )
  end
  
  describe "instance method" do
    
    describe "pubsub_jid" do
      it "should return the pubsub_jid" do
        p = pubsub_affiliation_factory :pubsub_jid => 'pubsub.foo.com'
        p.pubsub_jid.should == Jubjub::Jid.new('pubsub.foo.com')
      end
    end
    
    describe "pubsub_node" do
      it "should return the node" do
        p = pubsub_affiliation_factory :pubsub_node => 'node_1'
        p.pubsub_node.should == 'node_1'
      end
    end
    
    describe "jid" do
      it "should return the jid" do
        p = pubsub_affiliation_factory :jid => 'bob@foo.com'
        p.jid.should == Jubjub::Jid.new('bob@foo.com')
      end
    end
    
    describe "affiliation" do
      it "should return the affiliation" do
        p = pubsub_affiliation_factory :affiliation => 'publisher'
        p.affiliation.should == 'publisher'
      end
    end
    
    describe "owner?" do
      it "should return true when affiliation is 'owner'" do
        pubsub_affiliation_factory( :affiliation => 'owner' ).owner?.should equal(true)
      end
      
      it "should return false when affiliation is not 'owner'" do
        pubsub_affiliation_factory( :affiliation => 'publisher' ).owner?.should equal(false)
      end
    end
    
    describe "publisher?" do
      it "should return true when affiliation is 'publisher'" do
        pubsub_affiliation_factory( :affiliation => 'publisher' ).publisher?.should equal(true)
      end
      
      it "should return false when affiliation is not 'publisher'" do
        pubsub_affiliation_factory( :affiliation => 'owner' ).publisher?.should equal(false)
      end
    end
    
    describe "publish_only?" do
      it "should return true when affiliation is 'publish-only'" do
        pubsub_affiliation_factory( :affiliation => 'publish-only' ).publish_only?.should equal(true)
      end
      
      it "should return false when affiliation is not 'publish-only'" do
        pubsub_affiliation_factory( :affiliation => 'publisher' ).publish_only?.should equal(false)
      end
    end
    
    describe "member?" do
      it "should return true when affiliation is 'member'" do
        pubsub_affiliation_factory( :affiliation => 'member' ).member?.should equal(true)
      end
      
      it "should return false when affiliation is not 'member'" do
        pubsub_affiliation_factory( :affiliation => 'publisher' ).member?.should equal(false)
      end
    end
    
    describe "none?" do
      it "should return true when affiliation is 'none'" do
        pubsub_affiliation_factory( :affiliation => 'none' ).none?.should equal(true)
      end
      
      it "should return false when affiliation is not 'none'" do
        pubsub_affiliation_factory( :affiliation => 'publisher' ).none?.should equal(false)
      end
    end
    
    describe "outcast?" do
      it "should return true when affiliation is 'outcast'" do
        pubsub_affiliation_factory( :affiliation => 'outcast' ).outcast?.should equal(true)
      end
      
      it "should return false when affiliation is not 'outcast'" do
        pubsub_affiliation_factory( :affiliation => 'publisher' ).outcast?.should equal(false)
      end
    end
    
    describe "set" do
      it "should redirect call to pubsub.modify_affiliation" do
        @mock_connection = mock
        @mock_connection.stub_chain :pubsub, :modify_affiliations
        
        affiliation = pubsub_affiliation_factory :connection => @mock_connection
        
        @mock_connection.pubsub.should_receive(:modify_affiliations).with( affiliation.pubsub_jid, affiliation.pubsub_node, affiliation )
        
        affiliation.set 'publisher'
      end

      describe "when succesful" do
        before do
          @mock_connection = mock
          @mock_connection.stub_chain( :pubsub, :modify_affiliations ).and_return( true )
        end
        
        it "should return true" do
          @affiliation = pubsub_affiliation_factory :connection => @mock_connection
          @affiliation.set( 'publisher' ).should equal( true )
        end
        
        it "should have affiliaton set to new value" do
          @affiliation = pubsub_affiliation_factory :connection => @mock_connection, :affiliation => 'owner'
          @affiliation.set 'publisher'
          @affiliation.affiliation.should == 'publisher'
        end
      end
      
      describe "when unsuccesful" do
        before do
          @mock_connection = mock
          @mock_connection.stub_chain( :pubsub, :modify_affiliations ).and_return( false )
        end
        
        it "should return false" do
          @affiliation = pubsub_affiliation_factory :connection => @mock_connection
          @affiliation.set( 'publisher' ).should equal( false )
        end
        
        it "should have affiliaton set to original value" do
          @affiliation = pubsub_affiliation_factory :connection => @mock_connection, :affiliation => 'owner'
          @affiliation.set 'publisher'
          @affiliation.affiliation.should == 'owner'
        end
      end
    end
    
    describe "set_owner" do
      it "should redirect call to set" do
        affiliation = pubsub_affiliation_factory
        affiliation.should_receive(:set).with('owner').and_return( 'from-set' )
        
        affiliation.set_owner.should == 'from-set'
      end
    end
    
    describe "set_publisher" do
      it "should redirect call to set" do
        affiliation = pubsub_affiliation_factory
        affiliation.should_receive(:set).with('publisher').and_return( 'from-set' )
      
        affiliation.set_publisher.should == 'from-set'
      end
    end
    
    describe "set_publish_only" do
      it "should redirect call to set" do
        affiliation = pubsub_affiliation_factory
        affiliation.should_receive(:set).with('publish-only').and_return( 'from-set' )
      
        affiliation.set_publish_only.should == 'from-set'
      end
    end
    
    describe "set_member" do
      it "should redirect call to set" do
        affiliation = pubsub_affiliation_factory
        affiliation.should_receive(:set).with('member').and_return( 'from-set' )
      
        affiliation.set_member.should == 'from-set'
      end
    end
    
    describe "set_none" do
      it "should redirect call to set" do
        affiliation = pubsub_affiliation_factory
        affiliation.should_receive(:set).with('none').and_return( 'from-set' )
      
        affiliation.set_none.should == 'from-set'
      end
    end
    
    describe "set_outcast" do
      it "should redirect call to set" do
        affiliation = pubsub_affiliation_factory
        affiliation.should_receive(:set).with('outcast').and_return( 'from-set' )
      
        affiliation.set_outcast.should == 'from-set'
      end
    end
    
    describe "==" do
      it "should match equivalent objects" do
        pubsub_affiliation_factory.should == pubsub_affiliation_factory
      end
      
      it "should not distinguish between connections" do
        pubsub_affiliation_factory(:connection => 'wibble').should == pubsub_affiliation_factory(:connection => 'wobble')
      end
      
      it "should still match no matter how jid is initialized" do
        pubsub_affiliation_factory(:jid => 'foo@bar.com').should == pubsub_affiliation_factory(:jid => Jubjub::Jid.new('foo@bar.com'))
      end
      
      it "should still match no matter how pubsub_jid is initialized" do
        pubsub_affiliation_factory(:pubsub_jid => 'pubsub.bar.com').should == 
        pubsub_affiliation_factory(:pubsub_jid => Jubjub::Jid.new('pubsub.bar.com'))
      end
      
      it "should not match objects with different attributes" do
        pubsub_affiliation_factory(:pubsub_jid => 'a.b.com').should_not == pubsub_affiliation_factory
        pubsub_affiliation_factory(:pubsub_node => 'waggle').should_not == pubsub_affiliation_factory        
        pubsub_affiliation_factory(:jid => 'a.b.com').should_not == pubsub_affiliation_factory
        pubsub_affiliation_factory(:affiliation => 'member').should_not == pubsub_affiliation_factory
      end
    end
    
  end
  
end