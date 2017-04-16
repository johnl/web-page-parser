require 'rake'
require 'rake/testtask'
begin
  require 'rdoc/task'
rescue LoadError
end
require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = ['-rrubygems', '-O spec/spec.opts']
end


