["/../lib", "/../lib/searchable_record"].each do |file|
  $LOAD_PATH.unshift(File.dirname(__FILE__) << file)
end

require "rubygems"
require "active_support"
require "mocha"

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
