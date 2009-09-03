%w{
  meta
  util
  core
}.each do |f|
  require "searchable_record/#{f}"
end
