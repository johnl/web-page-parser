require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = Dir.glob("spec/**/*_spec.rb")
  t.spec_opts = ['-rrubygems', '-O spec/spec.opts']
end


