shared_examples_for "any data form" do
  
  describe "creating" do
    
    it "should understand XML to build object" do
      dataform_1 = xml_fixture 'dataform_1'
      dataform = subject.class.new(dataform_1)
      
      expected = {
        "public"      => { :type => "boolean",      :value => "", :label => "Public bot?" },
        "FORM_TYPE"   => { :type => "hidden",       :value => "jabber:bot", :label => nil},
        "invitelist"  => { :type => "jid-multi",    :value => [], :label=>"People to invite"},
        "description" => { :type => "text-multi",   :value => [], :label=>"Helpful description of your bot"},
        "password"    => { :type => "text-private", :value => "", :label=>"Password for special access"},
        "botname"     => { :type => "text-single",  :value => "", :label=>"The name of your bot"},
        "features"    => { :type => "list-multi",   :value => ["news", "search"], :label => "What features will the bot support?", :options => [
          {:value => "contests",  :label=>"Contests"},
          {:value => "news",      :label=>"News"},
          {:value => "polls",     :label=>"Polls"},
          {:value => "reminders", :label=>"Reminders"}, 
          {:value => "search",    :label=>"Search"}
        ]},
        "maxsubs"     => { :type => "list-single",  :value => "20", :label => "Maximum number of subscribers", :options => [
          { :value => "10",   :label=>"10"},
          { :value => "20",   :label=>"20"},
          { :value => "30",   :label=>"30"},
          { :value => "50",   :label=>"50"},
          { :value => "100",  :label=>"100"},
          { :value => "none", :label=>"None"}]}
      }
      
      dataform.fields.should == expected
    end
    
    it "should understand hash to build object" do
      params = {  
        "muc#roomconfig_allowvisitornickchange" => { :type => "boolean", :value => "1", :label => "Allow visitors to change nickname" },
        "muc#roomconfig_roomname" => { :type => "text-single", :value => "", :label => "Room title" },
        "muc#roomconfig_whois" => { 
          :type    => "list-single",
          :value   => "moderators",
          :label   => "Present real Jabber IDs to",
          :options => [
            { :value =>"moderators", :label => "moderators only" },
            { :value =>"anyone",     :label => "anyone" } ],
        },
        "muc#roomconfig_passwordprotectedroom" => { :type => "boolean", :value => "0", :label => "Make room password protected" }
      }
      
      config = subject.class.new params
            
      config.should be_a_kind_of subject.class
      config.fields.should == params
    end

    it "should throw an error if an unknown key is sent" do
      expect{ 
        subject.class.new( "foo" => { :type => "boolean", :value => "1", :label => "Foo", :oh_no => nil } )
      }.to raise_error( 
        Jubjub::ArgumentError,
        ":oh_no is not a recognised option for foo"
      )
    end
    
    it "should throw an error if a hash isn't passed in" do
      expect{ 
        subject.class.new( "config" )
      }.to raise_error( 
        Jubjub::ArgumentError,
        "please initialize with a hash of the format { 'foo' => {:type => 'boolean', :value => false, :label => 'Fooey'} }"
      )
    end
    
  end
  
  describe "instance method" do
        
    describe "[]" do
      context "for booleans" do
        before do
          @config = subject.class.new(
            "muc#roomconfig_allowinvites" => {
              :type  => "boolean",
              :label => "Whether to Allow Occupants to Invite Others",
              :value => "0"
            },
            "muc#roomconfig_moderatedroom" => {
              :type  => "boolean",
              :label => "Whether to Make Room Moderated",
              :value => "false"
            },
            "muc#roomconfig_changesubject" => {
              :type  => "boolean",
              :label => "Whether to Allow Occupants to Change Subject",
              :value => "1"
            },
            "muc#roomconfig_publicroom" => {
              :type  => "boolean",
              :label => "Whether to Allow Public Searching for Room",
              :value => "true"
            }
          )
        end
        
        it "should return false or true" do
          @config['muc#roomconfig_allowinvites'].should be_false
          @config['muc#roomconfig_moderatedroom'].should be_false
          
          @config['muc#roomconfig_changesubject'].should be_true
          @config['muc#roomconfig_publicroom'].should be_true
        end
      end
      
      context "for lists" do
        before do
          @config = subject.class.new(
            "muc#roomconfig_presencebroadcast" => {
              :type  => "list-multi",
              :label => "Roles for which Presence is Broadcast",
              :value => ["moderator", "participant", "visitor"],
              :options => [
                { :value => "visitor",     :label => "Visitor"     },
                { :value => "moderators",  :label => "Moderator"   },
                { :value => "participant", :label => "Participant" }
              ]
            },
            "muc#roomconfig_maxusers" => {
              :type  => "list-single",
              :label => "Maximum Number of Occupants",
              :value => "20",
              :options => [
                { :value => "10", :label => "10" },
                { :value => "20", :label => "20" },
                { :value => "30", :label => "30" },
                { :value => "40", :label => "40" }
              ]
            }
          )
        end
        
        it "should return an array for list-multi" do
          @config["muc#roomconfig_presencebroadcast"].should == ["moderator", "participant", "visitor"]
        end
        
        it "should return a single item for list-single" do
          @config["muc#roomconfig_maxusers"].should == "20"          
        end
      end
      
      context "for jids" do
        before do
          @config = subject.class.new(
            "muc#roomconfig_roomadmins" => {
              :type  => "jid-multi",
              :label => "Room Admins",
              :value => ["wiccarocks@shakespeare.lit", "hecate@shakespeare.lit"]
            },
            "special_jid" => {
              :type  => "jid-single",
              :label => "A special jid",
              :value => "foo@bar.com"
            }
          )
        end
        
        it "should return a Jubjub::Jid" do
          jids = [Jubjub::Jid.new("wiccarocks@shakespeare.lit"), Jubjub::Jid.new("hecate@shakespeare.lit")]
          
          @config['muc#roomconfig_roomadmins'].should == jids
          @config['special_jid'].should == Jubjub::Jid.new("foo@bar.com")
        end
      end
      
      context "for non existent options" do
        before do
          @config = subject.class.new(
            "foo" => {
              :type  => "text-single",
              :label => "Foo",
              :value => "Blurgh"
            }
          )
        end
        
        it "should return nil" do
          @config['made_up'].should be_nil
        end
      end
    end
    
    describe "[]=" do
      
      context "for booleans do" do
        before do
          @config = subject.class.new(
            "muc#roomconfig_allowinvites" => {
              :type  => "boolean",
              :label => "Whether to Allow Occupants to Invite Others",
              :value => "0"
            }
          )
        end
        
        it "should convert '0' to false" do
          @config["muc#roomconfig_allowinvites"] = '0'
          @config["muc#roomconfig_allowinvites"].should be_false
        end
        
        it "should convert '1' to true" do
          @config["muc#roomconfig_allowinvites"] = '1'
          @config["muc#roomconfig_allowinvites"].should be_true
        end
        
        it "should convert 'true' to true" do
          @config["muc#roomconfig_allowinvites"] = 'true'
          @config["muc#roomconfig_allowinvites"].should be_true
        end
        
        it "should convert 'false' to false" do
          @config["muc#roomconfig_allowinvites"] = 'false'
          @config["muc#roomconfig_allowinvites"].should be_false
        end
        
        it "should return false if something else" do
          @config["muc#roomconfig_allowinvites"] = 'wibble'
          @config["muc#roomconfig_allowinvites"].should be_false
        end
      end
      
      context "for multi types" do
        before do
          @config = subject.class.new(
            "muc#roomconfig_roomadmins" => {
              :type  => "jid-multi",
              :label => "Room Admins",
              :value => ["wiccarocks@shakespeare.lit", "hecate@shakespeare.lit"]
            }
          )
        end
        
        it "should accept an array" do
          @config['muc#roomconfig_roomadmins'] = ['giraffe@zoo', 'elephant@zoo']
          
          @config['muc#roomconfig_roomadmins'].should == [Jubjub::Jid.new('giraffe@zoo'), Jubjub::Jid.new('elephant@zoo')]
        end
        
        it "should convert to an array if it isn't" do
          @config['muc#roomconfig_roomadmins'] = 'giraffe@zoo'
          
          @config['muc#roomconfig_roomadmins'].should == [Jubjub::Jid.new('giraffe@zoo')]
        end
      end
      
      context "for list types" do
        before do
          @config = subject.class.new(
            "muc#roomconfig_presencebroadcast" => {
              :type  => "list-multi",
              :label => "Roles for which Presence is Broadcast",
              :value => ["moderator", "participant", "visitor"],
              :options => [
                { :value => "visitor",     :label => "Visitor"     },
                { :value => "moderators",  :label => "Moderator"   },
                { :value => "participant", :label => "Participant" }
              ]
            },
            "muc#roomconfig_maxusers" => {
              :type  => "list-single",
              :label => "Maximum Number of Occupants",
              :value => "20",
              :options => [
                { :value => "10", :label => "10" },
                { :value => "20", :label => "20" },
                { :value => "30", :label => "30" },
                { :value => "40", :label => "40" }
              ]
            }
          )
        end
        
        it "should set the value if it is a valid option" do
          @config['muc#roomconfig_maxusers'] = "10"
          @config['muc#roomconfig_maxusers'].should eql("10")
          
          @config['muc#roomconfig_presencebroadcast'] = ["visitor"]
          @config['muc#roomconfig_presencebroadcast'].should eql(["visitor"])          
        end
        
        it "should raise an error if the value isn't one of the options" do
          expect{
           @config['muc#roomconfig_maxusers'] = "50000" 
          }.to raise_error(
            Jubjub::ArgumentError,
            "50000 is not an accepted value please choose from 10, 20, 30, 40"
          )
          
          expect{
            @config['muc#roomconfig_presencebroadcast'] = ["superman", "moderators"]
          }.to raise_error(
            Jubjub::ArgumentError,
            "superman is not an accepted value please choose from visitor, moderators, participant"
          )
        end
      end
      
      context "for jid types" do
        before do
          @config = subject.class.new(
            "muc#roomconfig_roomadmins" => {
              :type  => "jid-multi",
              :label => "Room Admins",
              :value => ["wiccarocks@shakespeare.lit", "hecate@shakespeare.lit"]
            },
            "special_jid" => {
              :type  => "jid-single",
              :label => "A special jid",
              :value => "foo@bar.com"
            }
          )
        end
        
        it "should convert strings to jids" do
          @config['muc#roomconfig_roomadmins'] = ["foo@bar.com", "bar@foo.com"]
          @config['muc#roomconfig_roomadmins'].should == [Jubjub::Jid.new('foo@bar.com'), Jubjub::Jid.new('bar@foo.com')]

          @config['special_jid'] = "bar@foo.com"
          @config['special_jid'].should == Jubjub::Jid.new('bar@foo.com')
        end
        
        it "should accept jids" do
          @config['muc#roomconfig_roomadmins'] = [Jubjub::Jid.new('foo@bar.com'), Jubjub::Jid.new('bar@foo.com')]
          @config['muc#roomconfig_roomadmins'].should == [Jubjub::Jid.new('foo@bar.com'), Jubjub::Jid.new('bar@foo.com')]

          @config['special_jid'] = Jubjub::Jid.new('bar@foo.com')
          @config['special_jid'].should == Jubjub::Jid.new('bar@foo.com')
        end
      end
      
      context "for non existent fields" do
        before do
          @config = subject.class.new(
            "muc#roomconfig_roomadmins" => {
              :type  => "jid-multi",
              :label => "Room Admins",
              :value => ["wiccarocks@shakespeare.lit", "hecate@shakespeare.lit"]
            }
          )
        end
        
        it "should raise an error" do
          expect{ 
            @config['fooey'] = "bar"
          }.to raise_error(
            Jubjub::ArgumentError,
            "fooey is not a valid field"
          )
        end
      end
      
    end
    
    describe "fields" do
      it "should return all of the types, values, labels and options for each field" do
        params = {
          "allow_query_users"       => { :type => "boolean", :value => "1", :label => "Allow users to query other users" },
          "muc#roomconfig_maxusers" => {
            :type    => "list-single",
            :value   => "5",
            :label   => "Maximum Number of Occupants",
            :options => [
              { :value => "5",   :label => "5"   },
              { :value => "10",  :label => "10"  }
            ]
          }
        }
        
        adjusted_params = {
          "allow_query_users"       => { :type => "boolean", :value => false, :label => "Allow users to query other users" },
          "muc#roomconfig_maxusers" => {
            :type    => "list-single",
            :value   => "5",
            :label   => "Maximum Number of Occupants",
            :options => [
              { :value => "5",   :label => "5"   },
              { :value => "10",  :label => "10"  }
            ]
          }
        }
        
        config = subject.class.new(params)
        config.fields.should == params
        
        config['allow_query_users'] = false
        config.fields.should == adjusted_params
      end
    end
    
    describe "==" do
      it "should match the same room config" do        
        config_1 = subject.class.new("allow_query_users" => { :type => "boolean", :value => "1", :label => "Foo" } )
        config_2 = subject.class.new("allow_query_users" => { :type => "boolean", :value => "1", :label => "Foo" } )
        
        config_1.should == config_2
      end
      
      it "should not match a different room config" do
        config_1 = subject.class.new("allow_query_users" => { :type => "boolean", :value => "1", :label => "Foo" } )
        config_2 = subject.class.new("allow_query_users" => { :type => "boolean", :value => "0", :label => "Foo" } )
        
        config_1.should_not == config_2
      end
    end
    
    describe "settings" do
      before do
        @config = subject.class.new(
          "muc#roomconfig_allowvisitornickchange" => { :type => "boolean", :value => "1", :label => "Allow visitors to change nickname" },
          "muc#roomconfig_roomname" => { :type => "text-single", :value => "", :label => "Room title" },
          "muc#roomconfig_whois" => { 
            :type    => "list-single",
            :value   => "moderators",
            :label   => "Present real Jabber IDs to",
            :options => [
              { :value => "moderators", :label => "moderators only" },
              { :value => "anyone",     :label => "anyone" } ],
          },
          "muc#roomconfig_roomadmins" => {
            :type  => "jid-multi",
            :label => "Room Admins",
            :value => ["wiccarocks@shakespeare.lit", "hecate@shakespeare.lit"]
          },
          "muc#roomconfig_passwordprotectedroom" => { :type => "boolean", :value => "0", :label => "Make room password protected" }
        )
        
      end
      
      it "should generate hash of name and values" do
        @config.settings.should == {
          "muc#roomconfig_allowvisitornickchange" => [true],
          "muc#roomconfig_roomname" => [""],
          "muc#roomconfig_whois" => ["moderators"],
          "muc#roomconfig_roomadmins" => [Jubjub::Jid.new("wiccarocks@shakespeare.lit"), Jubjub::Jid.new("hecate@shakespeare.lit")],
          "muc#roomconfig_passwordprotectedroom" => [false]
        }
      end
    end

    describe "to_builder" do
      
      it "should return a Nokogiri::XML::Builder" do
        subject.to_builder.should be_a_kind_of Nokogiri::XML::Builder 
      end
      
      it "should be possible to merge this into another Nokogiri::Builder" do
        doc = Nokogiri::XML::Builder.new{|xml|
          xml.foo {
            subject.to_builder(xml.parent)
          }
        }.to_xml
        
        expected = "<?xml version=\"1.0\"?>\n<foo>\n  <x xmlns=\"jabber:x:data\" type=\"submit\"/>\n</foo>\n"
        
        doc.should == expected
      end
      
    end
    
  end
  
  describe "dynamic methods" do
    
    describe "<friendly name>= " do
      it "should return the same as []="
    end
    
    describe "<friendly name>" do
      it "should return the same as []"
    end
    
    describe "<friendly name>?" do
      it "should return label"
    end
    
    describe "<name>=" do
      it "should return the same as []="
    end
    
    describe "<name>" do
      it "should return the same as []"
    end
    
    describe "<name>?" do
      it "should return label"
    end
    
  end
  
end
