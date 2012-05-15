require 'spec_helper'

describe Jubjub::Muc::Collection do

  describe "instance methods" do

    describe "create" do

      before do
        @mock_connection = mock
        @mock_connection.stub(:jid).and_return( Jubjub::Jid.new 'admin@foo.com' )
        @mock_connection.stub_chain :muc, :create
      end

      it "should call muc.create on connection" do
        @mock_connection.muc.should_receive(:create).with( Jubjub::Jid.new 'hello@conference.foo.com/admin' )

        Jubjub::Muc::Collection.new("conference.foo.com", @mock_connection).create("hello")
      end

      it "should yield a Muc::Configuration if a block is given" do
        @config = Jubjub::Muc::Configuration.new( "allow_query_users" => { :type => "boolean", :value => "1", :label => "Foo" } )

        @mock_connection.muc.should_receive( :configuration ).with( Jubjub::Jid.new( 'hello@conference.foo.com/admin' )).and_return( @config )
        @mock_connection.muc.should_receive( :create        ).with( Jubjub::Jid.new( 'hello@conference.foo.com/admin' ), @config )

        Jubjub::Muc::Collection.new("conference.foo.com", @mock_connection).create("hello"){|config|
          config.should == @config
        }
      end

      it "should use supplied configuration if available and no block is given" do
        @config = Jubjub::Muc::Configuration.new( "allow_query_users" => { :type => "boolean", :value => "1", :label => "Foo" } )

        @mock_connection.muc.should_receive( :create ).with( Jubjub::Jid.new( 'hello@conference.foo.com/admin' ), @config )

        Jubjub::Muc::Collection.new("conference.foo.com", @mock_connection).create("hello", nil, @config)
      end

    end

    describe "jid" do
      it "should return the jid" do
        Jubjub::Muc::Collection.new("conference.foo.com", mock).jid.should == Jubjub::Jid.new("conference.foo.com")
      end
    end

    describe "[]" do
      before do
        @mock_connection = mock
        @rooms = [
          Jubjub::Muc.new('room_1@conference.foo.com', nil, @mock_connection),
          Jubjub::Muc.new('room_2@conference.foo.com', nil, @mock_connection)
        ]
        @mock_connection.stub_chain( :muc, :list ).and_return(@rooms)
      end

      subject { Jubjub::Muc::Collection.new('conference.foo.com', @mock_connection) }

      it "should work like a normal array when passed a Fixnum" do
        subject[1].should == @rooms[1]
      end

      describe "searching by node if a String" do

        it "should return cached result if it has already searched" do
          # Trigger lookup
          @mock_connection.muc.should_receive(:list)
          subject.first
          subject["room_1"].should == @rooms[0]
        end

        it "should return default result if it has already searched and does not exist" do
          # Trigger lookup
          @mock_connection.muc.should_receive(:list)
          subject.first
          subject['made-up'].should == Jubjub::Muc.new('made-up@conference.foo.com', nil, @mock_connection)
        end

        it "should return default result if it has not already searched" do
          @mock_connection.muc.should_not_receive(:list)
          subject["room_1"].should_not equal @rooms[0]
          subject["room_1"].should == Jubjub::Muc.new('room_1@conference.foo.com', nil, @mock_connection)
        end

      end

      describe "searching by jid if a Jubjub::Jid" do

        it "should return cached result if it has already searched" do
          # Trigger lookup
          @mock_connection.muc.should_receive(:list)
          subject.first
          subject[Jubjub::Jid.new("room_1@conference.foo.com")].should == @rooms[0]
        end

        it "should return default result if it has already searched and does not exist" do
          # Trigger lookup
          @mock_connection.muc.should_receive(:list)
          subject.first
          subject[Jubjub::Jid.new("made-up@conference.foo.com")].should == Jubjub::Muc.new('made-up@conference.foo.com', nil, @mock_connection)
        end

        it "should return default result if it has not already searched" do
          @mock_connection.muc.should_not_receive(:list)
          subject[Jubjub::Jid.new("room_1@conference.foo.com")].should_not equal @rooms[0]
          subject[Jubjub::Jid.new("room_1@conference.foo.com")].should == Jubjub::Muc.new('room_1@conference.foo.com', nil, @mock_connection)
        end

      end

    end

    describe "that are proxied like" do

      before do
        @mock_connection = mock
        @rooms = [
          Jubjub::Muc.new('room_1@conference.foo.com', nil, @mock_connection),
          Jubjub::Muc.new('room_2@conference.foo.com', nil, @mock_connection)
        ]
        @mock_connection.stub_chain( :muc, :list ).and_return(@rooms)
      end

      describe "inspect" do

        it "should show the list of rooms, not Muc::Collection" do
          Jubjub::Muc::Collection.new('conference.foo.com', @mock_connection).inspect.should eql(@rooms.inspect)
        end

      end

      describe "map" do

        it "should pass the block to the rooms" do
          c = Jubjub::Muc::Collection.new('conference.foo.com', @mock_connection)
          c.map{|r| r.jid.to_s }.should eql(['room_1@conference.foo.com', 'room_2@conference.foo.com'])
        end

      end
    end

  end

end
