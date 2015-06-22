require './monit_app'

# Rakefile
APP_FILE  = './app.rb'
APP_CLASS = 'MonitApp::Application'

require 'sinatra/assetpack/rake'


namespace :build do
  task :assets => ['assetpack:build'] do
    `cp -r $(bundle show bootstrap-sass)/vendor/assets/fonts/bootstrap public/assets/stylesheets/`
  end

end

