require 'rubygems'
require 'hoe'
require 'spec/rake/spectask'

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")

require 'searchable_record'

desc 'Default: run specs.'
task :default => :spec

Hoe.new('searchable_record', SearchableRecord::Meta::VERSION.to_s) do |p|
  p.name = "searchable_record"
  p.rubyforge_name = 'searchable-rec' # If different than lowercase project name
  p.author = "Tuomas Kareinen"
  p.email = 'tkareine@gmail.com'
  p.summary = "SearchableRecord is a small Ruby on Rails plugin that makes the parsing of
  query parameters from URLs easy for resources, allowing the requester to
  control the items (records) shown in the resource's representation."
  p.description = p.paragraphs_of('README.txt', 1..4).join("\n\n")
  p.url = "http://searchable-rec.rubyforge.org"
  # p.clean_globs = ['test/actual'] # Remove this directory on "rake clean"
  p.remote_rdoc_dir = '' # Release to root
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps = ['active_support']
end

desc "Run specs."
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts = ["--format", "specdoc"]
  #t.warning = true
end

desc "Search unfinished parts of source code."
task :todo do
  FileList['**/*.rb'].egrep /#.*(TODO|FIXME)/
end

# desc 'Spec test the plugin.'
# Rake::TestTask.new(:spec) do |t|
#   t.libs   << 'lib'
#   t.options = '-rs'
#   t.pattern = 'test/**/spec_*.rb'
#   t.verbose = true
# end
# 
# desc 'Generate documentation for the plugin.'
# Rake::RDocTask.new(:rdoc) do |t|
#   t.options << '--line-numbers' << '--inline-source'
#   t.title    = 'SearchableRecord documentation'
#   t.main     = 'README'
#   t.rdoc_dir = 'rdoc'
#   t.rdoc_files.include('README')
#   t.rdoc_files.include('lib/**/*.rb')
# end
