desc "the middleman related tasks"
namespace :middleman do

  desc "kickoff the preview server"
  task :server do
    server_cmd = "bundle exec middleman server"

    puts server_cmd
    system server_cmd
  end
end