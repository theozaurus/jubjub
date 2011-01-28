require 'spec_helper'

describe Jubjub::MucCollection do
  
  describe "instance methods" do
    
    describe "create" do
      
      it "should call muc.create on connection" do
        mock_connection = mock
        mock_connection.stub(:jid).and_return( Jubjub::Jid.new 'admin@foo.com' )
        mock_connection.stub_chain :muc, :create
        mock_connection.muc.should_receive(:create).with( Jubjub::Jid.new 'hello@conference.foo.com/admin' )
        
        Jubjub::MucCollection.new("conference.foo.com", mock_connection).create("hello")
      end
      
    end
    
    describe "jid" do
      it "should return the jid" do
        Jubjub::MucCollection.new("conference.foo.com", mock).jid.should == Jubjub::Jid.new("conference.foo.com")
      end
    end
    
    describe "that are proxied like" do
      
      before do
        @mock_connection = mock
        @rooms = [
          Jubjub::Muc.new('room_1', nil, @mock_connection),
          Jubjub::Muc.new('room_2', nil, @mock_connection)        
        ]
        @mock_connection.stub_chain( :muc, :list ).and_return(@rooms)
      end
      
      describe "inspect" do

        it "should show the list of rooms, not MucCollection" do
          Jubjub::MucCollection.new('conference.foo.com', @mock_connection).inspect.should eql(@rooms.inspect)
        end

      end

      describe "map" do

        it "should pass the block to the rooms" do
          c = Jubjub::MucCollection.new('conference.foo.com', @mock_connection)
          c.map{|r| r.jid.to_s }.should eql(['room_1', 'room_2'])
        end

      end
    end
    
  end
  
end