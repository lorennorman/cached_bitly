require 'bundler/gem_tasks'
require 'rake/testtask'

desc 'Default: run tests'
task :default => :test

desc 'Run CachedBitly tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end