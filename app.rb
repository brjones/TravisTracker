require 'rubygems'
require 'sinatra'
require 'travis'
require 'sinatra/config_file'


config_file "config.yml"


get '/' do
  @states = {"failed" => "danger", "passed" => "success", "errored" => "warning", "started" => "info", "created" => "info"}
  repos = []
  settings.projects.each do |repo_name|
    repos <<  Travis::Repository.find(repo_name)
  end
  @repos = repos.each_slice(3).to_a
  erb :'index'
end

