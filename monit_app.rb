require 'rubygems'
require 'sinatra/base'
require 'sinatra/config_file'
require 'tilt/erb'
require 'monit'

module MonitApp

  HOST_SERVICE_TYPE = '5'
  UNSPECIFIED_PROCESS = 'general'
  UNSPECIIFED_ENVIRONMENT = 'no_environment'

  class Application < Sinatra::Base

    register Sinatra::ConfigFile
    config_file "config.yml"

    get '/' do
      @status = Status.new(settings.monit)
      erb :'monit/index'
    end
  end

  ##
  # Retrieves monit status from each server provided and structures the information
  class Status

    def initialize(configs)
      @servers, @hosts = [], []
      @environments = Hash.new {|h,i| h[i] = Environment.new(i) }
      configs.each do |config|
        begin
          Monit::Status.new(config).tap do |status|
            status.get
            @servers << status.server
            status.services.each {|service| record_service(service) }
          end
        rescue Errno::ECONNREFUSED
          @servers << DeadServer.new(config[:host])
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
      return @hosts << service if service.service_type == HOST_SERVICE_TYPE
      service_name = ServiceName.new(service.name)
      environment(service_name.environment).record_service(service_name.application,service_name.process,service)
    end

  end

  class Environment

    attr_reader :name

    def initialize(name)
      @name = name
      @applications = Hash.new {|h,i| h[i] = MonitoredApplication.new(i) }
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

  end

  class MonitoredApplication
    attr_reader :name

    def initialize(name)
      @name = name
      @processes = []
    end

    def add_process(name,service)
      @processes << [name,service]
    end

  end

  ##
  # Helper class to assist with name parsing
  class ServiceName
    attr_reader :environment, :application, :process
    def initialize(name)
      name_array = name.split('/')
      name_array << UNSPECIFIED_PROCESS if name_array.length < 3
      name_array.unshift(UNSPECIIFED_ENVIRONMENT) if name_array.length < 3
      @environment = name_array.shift.humanize
      @application = name_array.shift.humanize
      @process     = name_array.join(' ').humanize
    end
  end

end
