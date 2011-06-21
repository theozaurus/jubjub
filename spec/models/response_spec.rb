require 'spec_helper'

describe Jubjub::Response do
  
  describe 'creating' do
    
    it 'should take a stanza' do
      stanza = xml_fixture 'dataform_1'
      
      response = Jubjub::Response.new stanza
      
      response.stanza.should == stanza
      response.result.should == nil
    end
    
    it 'should take a block to define result' do
      stanza = xml_fixture 'dataform_1'
      
      namespaces = {
        'commands' => 'http://jabber.org/protocol/commands',
        'x_data' => 'jabber:x:data'
      }
      
      response = Jubjub::Response.new( stanza ) do |s|
        s.xpath(
          "//iq[@type='result']/commands:command/x_data:x[@type='form']/x_data:instructions",
          namespaces
        ).text
      end
      
      response.result.should == 'Fill out this form to configure your new bot!'
    end
    
  end
  
  describe 'instance method' do
    
    describe 'result' do
      
      before { @stanza = xml_fixture 'dataform_1' }
      
      it 'should return result of block used in initialization if specified' do        
        Jubjub::Response.new( @stanza ){ "Result" }.result.should == "Result"
      end
      
      it 'should return nil if no block provided' do
        Jubjub::Response.new( @stanza ).result.should == nil
      end
      
    end
    
    describe 'proxy_result' do
      
      before { @stanza = xml_fixture 'dataform_1' }
      
      it 'should return proxy of result' do
        result = "Result"
        Jubjub::Response.new( @stanza ){ result }.proxy_result.should be_a_kind_of_response_proxied result.class
      end
      
    end
    
    describe 'success?' do
      it 'should return true when stanza is iq[@type="get"]' do
        xml = Nokogiri::XML::Document.parse "<iq type='get'/>"
        Jubjub::Response.new( xml ).success?.should equal(true)
      end
      
      it 'should return true when stanza is iq[@type="result"]' do
        xml = Nokogiri::XML::Document.parse "<iq type='result'/>"
        Jubjub::Response.new( xml ).success?.should equal(true)
      end
      
      it 'should return true when stanza is iq[@type="set"]' do
        xml = Nokogiri::XML::Document.parse "<iq type='set'/>"
        Jubjub::Response.new( xml ).success?.should equal(true)
      end
      
      it 'should return false when stanza is iq[@type="error"]' do
        xml = Nokogiri::XML::Document.parse "<iq type='error'/>"
        Jubjub::Response.new( xml ).success?.should equal(false)
      end
      
      it 'should not look at child iq elements' do
        xml = Nokogiri::XML::Document.parse "<totally><wrong><iq type='result'/></wrong></totally>"
        Jubjub::Response.new( xml ).success?.should equal(false)
      end
      
      it 'should return false when stanza is nonsensical' do
        xml = Nokogiri::XML::Document.parse "<presence/>"
        Jubjub::Response.new( xml ).success?.should equal(false)
      end
    end
    
    describe 'error' do
      
      it 'should return Jubjub::Response:Error object if error present' do
        xml = Nokogiri::XML::Document.parse "<iq type='error'><error><policy-violation xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'></error></iq>"
        r = Jubjub::Response.new( xml )
        r.error.should be_a Jubjub::Response::Error
        r.error.condition.should == "policy-violation"
      end
      
      it 'should return nil if error is not present' do
        xml = Nokogiri::XML::Document.parse "<iq type='set'/>"
        Jubjub::Response.new( xml ).error.should be_nil
      end
      
    end
    
  end
  
end