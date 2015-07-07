require './monit_app'

# Rakefile
APP_FILE  = './app.rb'
APP_CLASS = 'MonitApp::Application'

 task :default => 'build'

task :build do
  `cp -r ./assets/stylesheets ./public/`
  `cp -r ./assets/javascripts ./public/`
end

