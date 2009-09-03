$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

require "rubygems"

package_name = "searchable_record"
full_name = "SearchableRecord"
require "#{package_name}"
version = SearchableRecord::VERSION

require "hoe"
Hoe.spec package_name do
  self.url = "http://searchable-rec.rubyforge.org/searchable_record/"
  self.summary = "A Rails plugin that helps parsing query parameters from URLs"
  self.description = <<-END
SearchableRecord is a small Ruby on Rails plugin that makes the parsing of
query parameters from URLs easy for resources, allowing the requester to
control the items (records) shown in the resource's representation.
  END

  developer "Tuomas Kareinen", "tkareine@gmail.com"

  self.extra_deps << ["activesupport", ">= 2.1.0"]

  self.readme_file = "README.rdoc"
  self.history_file = "CHANGELOG.rdoc"
  self.extra_rdoc_files = FileList["*.rdoc"].to_a
  self.spec_extras = {
    :rdoc_options => [
      "--title", "#{full_name} #{version}",
      "--main",  "README.rdoc",
      "--exclude", "spec",
      "--line-numbers"
    ]
  }

  self.rubyforge_name = "searchable-rec"

  self.rspec_options = ["--colour --format progress --loadby mtime"]
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
