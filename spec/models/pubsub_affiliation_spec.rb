require 'spec_helper'

describe Jubjub::Pubsub::Affiliation do
  
  def pubsub_affiliation_factory(override = {})
    options = {
      :jid         => Jubjub::Jid.new("theozaurus@foo.com"),
      :affiliation => 'owner',
      :connection  => "SHHHH CONNECTION OBJECT"
    }.merge( override )
    
    Jubjub::Pubsub::Affiliation.new(
      options[:jid],
      options[:affiliation],
      options[:connection]
    )
  end
  
  describe "instance method" do
    
    describe "jid" do
      it "should return the jid" do
        p = pubsub_affiliation_factory :jid => 'foo.com'
        p.jid.should == Jubjub::Jid.new('foo.com')
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
      
      it "should not match objects with different attributes" do
        pubsub_affiliation_factory(:jid => 'a.b.com').should_not == pubsub_affiliation_factory
        pubsub_affiliation_factory(:affiliation => 'member').should_not == pubsub_affiliation_factory
      end
    end
    
  end
  
end