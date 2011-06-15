require 'spec_helper'

class User
  include Jubjub::User
end

describe Jubjub::User do
  
  describe 'class method' do
    
    describe 'jubjub' do
      
      it 'should require :jid option' do
        expect { 
          User.instance_eval{ jubjub_client :password => :foo }
        }.to raise_error(
          Jubjub::ArgumentError,
          'missing :jid option'
        )
      end
      
      it 'should require :password option' do
        expect {
          User.instance_eval{ jubjub_client :jid => :foo }
        }.to raise_error(
          Jubjub::ArgumentError,
          'missing :password option'
        )
      end
      
      it 'should setup jubjub_jid' do
        User.instance_eval{ jubjub_client :jid => :foo, :password => :bar }
        
        u = User.new
        u.stub(:foo).and_return('hello@jiggery')

        u.jubjub_jid.should be_kind_of(Jubjub::Jid)
        u.jubjub_jid.to_s.should eql('hello@jiggery')
      end
      
      it 'should setup jubjub_password' do
        User.instance_eval{ jubjub_client :jid => :foo, :password => :bar }
        
        u = User.new
        u.stub(:bar).and_return('secr3t')

        u.jubjub_password.should eql('secr3t')
      end
      
      describe 'connection settings' do
        it 'should use sensible defaults' do
          User.instance_eval{ jubjub_client :jid => :jid, :password => :password }
          
          u = User.new
          u.jubjub_connection_settings.should eql( :host => '127.0.0.1', :port => '8000' )
        end
        
        it 'should have :host overrideable' do
          User.instance_eval{ jubjub_client :jid => :jid, :password => :password, :connection_settings => {:host => '192.168.1.1'} }
          
          u = User.new
          u.jubjub_connection_settings.should eql( :host => '192.168.1.1', :port => '8000' )
        end
        
        it 'should have :port overrideable' do
          User.instance_eval{ jubjub_client :jid => :jid, :password => :password, :connection_settings => {:port => '7000'} }
          
          u = User.new
          u.jubjub_connection_settings.should eql( :host => '127.0.0.1', :port => '7000' )
        end
      end
      
    end
    
  end
  
  describe 'instance method' do
    def mock_jubjub_connection
      @jubjub_connection = mock
      @user.stub(:jubjub_connection).and_return(@jubjub_connection)
    end
    
    before do
      User.instance_eval{ jubjub_client :jid => :jid, :password => :password }
      
      @user = User.new
      @user.stub(:jid).and_return('theozaurus@biggles.com')
      @user.stub(:password).and_return('123')
    end

    describe 'jubjub_connection' do
      it 'should return Jubjub::Connection::XmppGateway instance' do
        @user.jubjub_connection.should be_kind_of(Jubjub::Connection::XmppGateway)
      end
      
      it 'should call Jubjub::Connection::XmppGateway with correct options' do
        @user.stub(:jubjub_jid).and_return('theozaurus@biggles.com')
        @user.stub(:jubjub_password).and_return('123')
        @user.stub(:jubjub_connection_settings).and_return(:host => 'zippy', :port => '1234')
        
        Jubjub::Connection::XmppGateway.should_receive(:new).with('theozaurus@biggles.com', '123', {:host => 'zippy', :port => '1234'} )
        
        @user.jubjub_connection
      end      
    end

    describe 'authenticated?' do
      before do
        mock_jubjub_connection
      end
       
      it 'should call authenticated on jubjub_connection' do
        @jubjub_connection.should_receive(:authenticated?)      
        
        @user.authenticated?
      end
    end
    
    describe 'mucs' do
      before do
        mock_jubjub_connection
      end
         
      it 'should return Jubjub::Muc::Collection for conference.biggles.com when no service specified' do        
        @user.mucs.should be_a Jubjub::Muc::Collection
        @user.mucs.jid.should == Jubjub::Jid.new('conference.biggles.com')
      end
      
      it 'should return Jubjub::Muc::Collection for service when specified' do
        @user.mucs('wibble.com').should be_a Jubjub::Muc::Collection
        @user.mucs('wibble.com').jid.should == Jubjub::Jid.new('wibble.com')
      end
    end
    
    describe 'pubsub' do
      before do
        mock_jubjub_connection
      end
         
      it 'should return Jubjub::Pubsub::Collection for conference.biggles.com when no service specified' do        
        @user.pubsub.should be_a Jubjub::Pubsub::Collection
        @user.pubsub.jid.should == Jubjub::Jid.new('pubsub.biggles.com')
      end
      
      it 'should return Jubjub::Pubsub::Collection for service when specified' do
        @user.pubsub('wibble.com').should be_a Jubjub::Pubsub::Collection
        @user.pubsub('wibble.com').jid.should == Jubjub::Jid.new('wibble.com')
      end
    end

  end
  
end