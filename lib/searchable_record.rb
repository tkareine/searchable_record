%w(version util core).each do |file|
  require "searchable_record/#{file}"
end
