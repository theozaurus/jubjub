require 'spec_helper'

describe Jubjub::Muc do

  describe "instance method" do

    describe "inspect" do

      it "should not show connection information" do
        m = Jubjub::Muc.new(Jubjub::Jid.new("hello@conference.foo.com"),nil,"SHHHH CONNECTION OBJECT")
        m.inspect.should_not match 'SHHHH CONNECTION OBJECT'
      end

      it "should show string version of jid" do
        m = Jubjub::Muc.new(Jubjub::Jid.new("hello@conference.foo.com"),nil,mock)
        m.inspect.should match 'hello@conference.foo.com'
      end

      it "should show name" do
        m = Jubjub::Muc.new(Jubjub::Jid.new("hello@conference.foo.com"),nil,mock)
        m.inspect.should match '@name=nil'

        m = Jubjub::Muc.new(Jubjub::Jid.new("hello@conference.foo.com"),"Hey there",mock)
        m.inspect.should match '@name="Hey there"'
      end

    end

    describe "jid" do
      it "should return the jid object" do
        Jubjub::Muc.new("hello@conference.foo.com",nil,mock).jid.should == Jubjub::Jid.new("hello@conference.foo.com")
      end
    end

    describe "name" do
      it "should return the name" do
        Jubjub::Muc.new("hello@conference.foo.com",nil,mock).name.should be_nil
        Jubjub::Muc.new("hello@conference.foo.com","bar",mock).name.should eql("bar")
      end
    end

    describe "message" do

      before do
        @mock_connection = mock
        @mock_connection.stub_chain :muc, :message
      end

      it "should call muc.message on connection" do
        jid = Jubjub::Jid.new "room@conference.foo.com"
        @mock_connection.muc.should_receive( :message ).with( jid, "rrrrspec" )

        Jubjub::Muc.new( jid, nil, @mock_connection ).message( "rrrrspec" )
      end

      it "should be chainable" do
        room = Jubjub::Muc.new("room@conference.foo.com", nil, @mock_connection)
        room.message("whoop").should eql room
      end

    end

    describe "exit" do
      before do
        muc_mock = mock
        muc_mock.stub(:exit) # exit doesn't work in a stub chain, manually build it

        @mock_connection = mock
        @mock_connection.stub(:jid).and_return( Jubjub::Jid.new 'nick@foo.com' )
        @mock_connection.stub(:muc).and_return( muc_mock )
      end

      it "should call muc.exit on connection" do
        @mock_connection.muc.should_receive(:exit).with( Jubjub::Jid.new 'room@conference.foo.com/nick' )

        Jubjub::Muc.new("room@conference.foo.com",nil,@mock_connection).exit
      end

      it "should support custom nick name" do
        @mock_connection.muc.should_receive(:exit).with( Jubjub::Jid.new 'room@conference.foo.com/custom_nick' )

        Jubjub::Muc.new("room@conference.foo.com",nil,@mock_connection).exit('custom_nick')
      end

      it "should be chainable" do
        room = Jubjub::Muc.new("room@conference.foo.com",nil,@mock_connection)
        room.exit.should eql room
      end
    end

    describe "destroy" do

      it "should call muc.destroy on connection" do
        mock_connection = mock
        mock_connection.stub_chain :muc, :destroy
        mock_connection.muc.should_receive(:destroy).with( Jubjub::Jid.new 'hello@conference.foo.com' )

        m = Jubjub::Muc.new('hello@conference.foo.com',nil,mock_connection)
        m.destroy
      end

    end

  end

end
