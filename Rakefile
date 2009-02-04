require "rubygems"
require "spec/rake/spectask"
require File.dirname(__FILE__) << "/lib/searchable_record/version"
require "echoe"

task :default => :spec

Echoe.new("searchable_record") do |p|
  p.author = "Tuomas Kareinen"
  p.email = "tkareine@gmail.com"
  p.project = "searchable-rec" # If different than the project name in lowercase.
  p.version = SearchableRecord::Version.to_s
  p.url = "http://searchable-rec.rubyforge.org/searchable_record/"
  p.summary =<<-END
SearchableRecord is a small Ruby on Rails plugin that makes the parsing of
query parameters from URLs easy for resources, allowing the requester to
control the items (records) shown in the resource's representation.
  END
  p.runtime_dependencies = %w(activesupport)
  p.ignore_pattern = "release-script.txt"
  p.rdoc_pattern = ["*.rdoc", "lib/**/*.rb"]
end

desc "Run specs."
Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_files = FileList["spec/**/*.rb"]
  t.spec_opts = ["--format", "specdoc"]
  #t.warning = true
end

desc "Find code smells."
task :roodi do
  sh("roodi '**/*.rb'")
end

desc "Search unfinished parts of source code."
task :todo do
  FileList["**/*.rb"].egrep /#.*(TODO|FIXME)/
end
