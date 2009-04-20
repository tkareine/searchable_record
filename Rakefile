require "rubygems"
require File.dirname(__FILE__) << "/lib/searchable_record/version"

require "hoe"
Hoe.new("searchable_record", SearchableRecord::Meta::VERSION.to_s) do |p|
  p.url = "http://searchable-rec.rubyforge.org/searchable_record/"
  p.summary =<<-END
SearchableRecord is a small Ruby on Rails plugin that makes the parsing of
query parameters from URLs easy for resources, allowing the requester to
control the items (records) shown in the resource's representation.
  END

  p.author = "Tuomas Kareinen"
  p.email = "tkareine@gmail.com"

  p.extra_deps = [["activesupport", ">= 2.1.0"]]
  p.readme_file = "README.rdoc"
  p.history_file = "CHANGELOG.rdoc"
  p.extra_rdoc_files = FileList["*.rdoc"].to_a
  p.spec_extras = {
    :rdoc_options => [
      "--title", "SearchableRecord #{p.version}",
      "--main",  "README.rdoc",
      "--exclude", "spec",
      "--line-numbers"
    ]
  }

  p.rubyforge_name = "searchable-rec"
end

require "spec/rake/spectask"
desc "Run specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList["spec/**/*.rb"]
  t.spec_opts = ["--colour --format progress --loadby mtime"]
  #t.warning = true
end

desc "Run specs with RCov"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_files = FileList["spec/**/*.rb"]
  t.spec_opts = ["--format", "specdoc"]
  t.rcov = true
  t.rcov_opts = ["--exclude", "spec"]
end

desc "Find code smells"
task :roodi do
  sh("roodi '**/*.rb'")
end

desc "Search unfinished parts of source code"
task :todo do
  FileList["**/*.rb"].egrep /#.*(TODO|FIXME)/
end

task :default => :spec
