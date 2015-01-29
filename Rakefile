require 'bundler/setup'
require 'middleman-gh-pages'

# Import namespaces from /tasks
Dir.glob('tasks/*.rake').each { |r| import r }

task :server do
  Rake::Task["middleman:server"].invoke
end