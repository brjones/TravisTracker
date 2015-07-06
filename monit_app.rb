require 'rubygems'
require 'sinatra/base'
require 'sinatra/config_file'
require 'tilt/erb'
require 'monit'

require 'sass'
require 'bootstrap-sass'


require 'pry'

require './models/monit/reader'
require './models/monit/service_reader'
require './models/monit/host_reader'
require './models/service_presenter'


module MonitApp


  UNSPECIIFED_ENVIRONMENT = 'no_environment'
  class Application < Sinatra::Base

    register Sinatra::ConfigFile
    config_file "config.yml"

    get '/' do
      settings.token_excluding_list.each {|name| ServicePresenter.add_name_to_token_excluding_list(name) }
      @status = Status.new(settings.monit)
      erb :'monit/index'
    end
  end

  class DeadServer
    def initialize(config)
      @config=config
    end
    def name
      @config[:host]
    end
    def is_dead?
      true
    end
  end

  ##
  # Retrieves monit status from each server provided and structures the information
  class Status

    def initialize(configs)
      #@servers,
      @hosts = []
      @environments = Hash.new {|h,i| h[i] = Environment.new(i) }
      configs.each do |config|
        begin
          Monit::Status.new(config).tap do |status|
            valid = status.get
            if valid
              status.services.each {|service| record_service(service) }
            else
              @hosts << DeadServer.new(config)
            end
          end
        rescue Errno::ECONNREFUSED
          @hosts << DeadServer.new(config)
        end
      end
    end

    def environment(name)
      @environments[name]
    end

    def each_environment
      @environments.values.each do |environment|
        yield environment
      end
    end

    def each_host
      @hosts.each do |host|
        yield host
      end
    end

    def record_service(service)
      service_presenter = ServicePresenter.new(service)
      return @hosts << service_presenter if service_presenter.is_host_service?
      environment(service_presenter.environment).record_service(service_presenter.application,service_presenter.process,service_presenter)
    end

  end

  class Environment

    attr_reader :name

    def id
      name.gsub(/ /,"-")
    end

    def ref_name
      id
    end

    def initialize(name)
      @name = name
      @applications = Hash.new {|h,i| h[i] = MonitoredApplication.new(i, self) }
    end

    def application(name)
      @applications[name]
    end

    def record_service(application_name,process,service)
      application(application_name).add_process(process,service)
    end

    def each_application
      @applications.values.each do |application|
        yield application
      end
    end

    def state_description
      return "success" if @applications.values.map(&:state_description).all?{|v| v=="success"}
      return "danger"
    end

  end

  class MonitoredApplication
    attr_reader :name

    def ref_name
      @environment.ref_name + name
    end

    def initialize(name, environment)
      @name = name
      @environment = environment
      @processes = []
    end

    def add_process(name,service)
      @processes << [name,service]
    end

    def state
      @processes.all?{|name, service| service.is_success_state?}
    end

    def state_description
      state ? 'success' : 'danger'
    end


    def each_process
      @processes.each do |name, service|
        yield name, service
      end
    end

  end

end
