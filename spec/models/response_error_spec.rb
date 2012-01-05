require 'spec_helper'

describe Jubjub::Response::Error do

  describe 'creating' do

    it 'should take a stanza' do
      xml = Nokogiri::XML::Document.parse "<error type='cancel'><feature-not-implemented xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/></error>"

      response = Jubjub::Response::Error.new xml

      response.stanza.should == xml
    end

  end

  describe 'instance method' do

    describe 'condition' do
      it 'should return a "urn:ietf:params:xml:ns:xmpp-stanzas" error condition' do
        xml = Nokogiri::XML::Document.parse "<error><bad-request xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'></error>"
        Jubjub::Response::Error.new( xml ).condition.should == "bad-request"
      end

      it 'should return nil if unknown' do
        xml = Nokogiri::XML::Document.parse "<error><text>Something went wrong</text><error/>"
        Jubjub::Response::Error.new( xml ).condition.should equal(nil)
      end
    end

    describe 'type' do
      it 'should return nil if no error type available' do
        xml = Nokogiri::XML::Document.parse "<error/>"
        Jubjub::Response::Error.new( xml ).type.should equal(nil)
      end

      it 'should return value errors present' do
        xml = Nokogiri::XML::Document.parse "<error type='cancel'/>"
        Jubjub::Response::Error.new( xml ).type.should == 'cancel'
      end
    end

    describe 'text' do
      it 'should return empty string if no text is available' do
        xml = Nokogiri::XML::Document.parse "<error type='cancel'/>"
        Jubjub::Response::Error.new( xml ).text.should == ""
      end

      it 'should return the text if available' do
        xml = Nokogiri::XML::Document.parse "<error type='cancel'><text>Hello!</text></error>"
        Jubjub::Response::Error.new( xml ).text.should == "Hello!"
      end

      it 'should return all text if available if multiple locales available' do
        xml = Nokogiri::XML::Document.parse "<error type='cancel'><text xml:lang='en'>Hello!</text><text xml:lang='fr'>Bonjour!</text></error>"
        Jubjub::Response::Error.new( xml ).text.should == "Hello!Bonjour!"
      end

      it 'should return the text in the correct locale if language specified' do
        xml = Nokogiri::XML::Document.parse "<error type='cancel'><text xml:lang='en'>Hello!</text><text xml:lang='fr'>Bonjour!</text></error>"
        Jubjub::Response::Error.new( xml ).text('fr').should == "Bonjour!"
        Jubjub::Response::Error.new( xml ).text('en').should == "Hello!"
      end
    end
  end


end
