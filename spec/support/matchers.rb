RSpec::Matchers.define :be_a_kind_of_response_proxied do |secondary_class| 
  match do |proxy|
    proxy.proxy_class == Jubjub::Response::Proxy && 
    proxy.proxy_primary.class == Jubjub::Response && 
    proxy.proxy_secondary.class == secondary_class
  end
end