require 'rake'
require 'rake/testtask'
require 'minitest/unit'

Rake::TestTask.new do |t|
  t.libs << "test"
  # t.name = "assess minitest tests"
  t.verbose = true
  t.warning = true
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
