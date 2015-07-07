require 'bootstrap-sass'
require './app'
require './monit_app'

use Rack::Static, :urls => ['/vendor'], :root => 'public'

map('/') do
  run TravisTracker
end

map('/monit') do
  run MonitApp::Application
end

