require 'spec_helper'

describe Jubjub::Jid do

  describe "creating" do

    describe "from a string" do

      it("should understand 'foo.bar'") do
        j = Jubjub::Jid.new('foo.bar')

        j.node.should be_nil
        j.domain.should eql('foo.bar')
        j.resource.should be_nil
      end

      it("should understand 'bob@foo.bar'") do
        j = Jubjub::Jid.new('bob@foo.bar')

        j.node.should eql('bob')
        j.domain.should eql('foo.bar')
        j.resource.should be_nil
      end

      it("should understand 'bob@foo.bar/wibble'") do
        j = Jubjub::Jid.new('bob@foo.bar/wibble')

        j.node.should eql('bob')
        j.domain.should eql('foo.bar')
        j.resource.should eql('wibble')
      end

    end

    describe "from components" do

      it("should understand nil, 'foo.bar', nil") do
        j = Jubjub::Jid.new(nil, 'foo.bar', nil)

        j.node.should be_nil
        j.domain.should eql('foo.bar')
        j.resource.should be_nil
      end

      it("should understand 'bob', 'foo.bar', nil") do
        j = Jubjub::Jid.new('bob','foo.bar',nil)

        j.node.should eql('bob')
        j.domain.should eql('foo.bar')
        j.resource.should be_nil
      end

      it("should understand 'bob','foo.bar','wibble'") do
        j = Jubjub::Jid.new('bob','foo.bar','wibble')

        j.node.should eql('bob')
        j.domain.should eql('foo.bar')
        j.resource.should eql('wibble')
      end

    end

    describe "from a Jubjub::Jid" do
      it("should understand Jid.new('foo.bar')") do
        j = Jubjub::Jid.new( Jubjub::Jid.new('foo.bar') )

        j.node.should be_nil
        j.domain.should eql('foo.bar')
        j.resource.should be_nil
      end

      it("should understand Jid.new('bob@foo.bar')") do
        j = Jubjub::Jid.new( Jubjub::Jid.new('bob@foo.bar') )

        j.node.should eql('bob')
        j.domain.should eql('foo.bar')
        j.resource.should be_nil
      end

      it("should understand Jid.new('bob@foo.bar/wibble')") do
        j = Jubjub::Jid.new( Jubjub::Jid.new('bob@foo.bar/wibble') )

        j.node.should eql('bob')
        j.domain.should eql('foo.bar')
        j.resource.should eql('wibble')
      end
    end

  end

  describe "instance method" do

    describe "to_s" do

      it "should support just a domain" do
        j = Jubjub::Jid.new nil, 'biggles.com'

        j.to_s.should eql('biggles.com')
      end

      it "should support a node and a domain" do
        j = Jubjub::Jid.new 'theozaurus', 'biggles.com'

        j.to_s.should eql('theozaurus@biggles.com')
      end

      it "should support a node, domain and resource" do
        j = Jubjub::Jid.new 'theozaurus', 'biggles.com', 'rocket'

        j.to_s.should eql('theozaurus@biggles.com/rocket')
      end

      it "should support a domain and resource" do
        j = Jubjub::Jid.new nil, 'biggles.com', 'bingo'

        j.to_s.should eql('biggles.com/bingo')
      end

    end

  end

end
