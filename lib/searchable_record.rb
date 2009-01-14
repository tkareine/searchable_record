unless defined? ActiveSupport
  require "rubygems"
  gem "activesupport"
  require "active_support"
end

%w(util version core).each do |file|
  require "searchable_record/#{file}"
end
