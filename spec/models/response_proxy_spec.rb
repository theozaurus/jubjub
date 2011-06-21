describe Jubjub::Response::Proxy do
  
  describe "creating" do
    
    it "should require proxy_primary, proxy_secondary and public_method" do
      primary = "String"
      secondary = ["Array"]
      
      p = Jubjub::Response::Proxy.new primary, secondary, "to_s"

      p.proxy_primary.should equal(primary)
      p.proxy_secondary.should equal(secondary)
    end
    
  end
  
  describe "proxied methods" do
    
    before do
      @primary_class = Class.new do
        def abc() end
        def efg() end
        def xyz() end
      end
      
      @secondary_class = Class.new do
        def abc() end # Same as primary
        def efg() end # Same as primary
        def cba() end # Does not exist on primary
      end
      
      @primary = @primary_class.new
      @secondary = @secondary_class.new
    end
    
    subject { Jubjub::Response::Proxy.new @primary, @secondary, 'efg' }
    
    describe "that exist on proxy_primary" do
      
      it "should not defer the primary_method" do
        @primary.should_receive(:efg).never
        
        subject.efg
      end
      
      it "should not defer methods that belong to Object.public_methods" do
        @primary.should_receive(:class).never
        
        subject.class
      end
      
      it "should defer to the proxy_primary" do
        @primary.should_receive(:abc)
        
        subject.abc
      end
      
    end
    
    describe "that don't defer to proxy_primary" do
      
      it "should defer to proxy_secondary" do
        @secondary.should_receive(:cba)
        
        subject.cba
      end
      
      it "should defer Object.public_methods to proxy_secondary" do
        @secondary.should_receive(:class)
        
        subject.class
      end
      
      it "should defer to proxy_secondary if primary_method" do
        @secondary.should_receive(:efg)
        
        subject.efg
      end
      
      it "should blow up if it doesn't exist on proxy_secondary either" do
        expect {
          subject.explode
        }.to raise_error(NoMethodError,"undefined method `explode' for #{@secondary.inspect}")
      end
      
    end
    
  end
  
  describe "instance method" do
    
    describe "inspect" do
    
      it "should really inspect proxy_secondary" do
        # The proxy_primary is just a thin layer over the top of the proxy_secondary
        # So make sure inspect shows us the proxy_secondary
        primary = "String"
        secondary = ["Array"]

        p = Jubjub::Response::Proxy.new primary, secondary, "to_s"
        
        p.inspect.should == secondary.inspect
      end
      
    end
    
    describe "proxy_primary" do
      
      it "should return the proxy_primary object" do
        primary = "p"
        
        proxy = Jubjub::Response::Proxy.new primary, "s", "to_s"
        
        proxy.proxy_primary.should equal(primary)
      end
      
    end
    
    describe "proxy_secondary" do
      
      it "should return the proxy_secondary object" do
        secondary = "p"
        
        proxy = Jubjub::Response::Proxy.new "p", secondary, "to_s"
        
        proxy.proxy_secondary.should equal(secondary)
      end
      
    end
    
    describe "proxy_class" do
      
      it "should return Jubjub::Response::Proxy" do
        p = Jubjub::Response::Proxy.new "p", "s", "to_s"
        
        p.proxy_class.should equal(Jubjub::Response::Proxy)
      end
      
    end
    
  end
  
end