require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = ['-rrubygems', '-O spec/spec.opts']
end


