require 'rubygems'
require 'sinatra/base'
require 'sinatra/config_file'
require 'tilt/erb'
require 'monit'

require 'sass'
require 'bootstrap-sass'

require 'sinatra/assetpack'

require 'pry'


module MonitApp


  HOST_SERVICE_TYPE = '5'
  UNSPECIFIED_PROCESS = 'general'
  UNSPECIIFED_ENVIRONMENT = 'no_environment'

  class Application < Sinatra::Base

    set :root, File.dirname(__FILE__) # You must set app root
    register Sinatra::AssetPack

    # assets do

    #   serve '/assets/javascripts', :from => 'assets/javascripts'
    #   serve '/assets/stylesheets', :from => 'assets/stylesheets'

    #   css :application, '/assets/stylesheets/application.css', [
    #     '/assets/stylesheets/*.css',
    #   ]

    #   js :application, '/assets/javascripts/app.js', [
    #     '/assets/javascripts/jquery.min.js',
    #     '/assets/javascripts/bootstrap.min.js',
    #     '/assets/javascripts/application.js'
    #   ]

    #   js_compression :jsmin
    #   css_compression :sass
    # end


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
      service_presenter = ServicePresenter.new(service)
      return @hosts << service_presenter if service_presenter.is_host_service?
      environment(service_presenter.environment).record_service(service_presenter.application,service_presenter.process,service_presenter)
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

    def state
      @processes.all?{|name, service| service.is_success_state?}
    end

    def state_description
      state ? 'success' : 'error'
    end

    def get_monitor(service)
      #  service.monitor
        # if (s->monitor == MONITOR_NOT)
        #         snprintf(buf, buflen, "Not monitored");
        # else if (s->monitor & MONITOR_WAITING)
        #         snprintf(buf, buflen, "Waiting");
        # else if (s->monitor & MONITOR_INIT)
        #         snprintf(buf, buflen, "Initializing");
        # else if (s->monitor & MONITOR_YES)
        #         snprintf(buf, buflen, "Monitored");

      # monitormode
        #{"active", "passive", "manual"};
      # pendingaction
      #define ACTION_IGNORE      0
#define ACTION_ALERT       1
#define ACTION_RESTART     2
#define ACTION_STOP        3
#define ACTION_EXEC        4
#define ACTION_UNMONITOR   5
#define ACTION_START       6
#define ACTION_MONITOR     7

    end


    def each_process

      @processes.each do |name, service|
        yield name, service
      end
    end
  end

  class ServicePresenter
    attr_reader :environment, :application, :process
    def initialize(service)
      @service = service
      name_array = service.name.split('.')
      name_array << UNSPECIFIED_PROCESS if name_array.length < 3
      name_array.unshift(UNSPECIIFED_ENVIRONMENT) if name_array.length < 3
      @environment = name_array.shift.humanize
      @application = name_array.shift.humanize
      @process     = name_array.join(' ').humanize
    end

    def is_success_state?
      @service.state == 0
    end

    def name
      @service.name
    end

    def state
      is_success_state? ? 'success' : 'error'
    end
    def monitor_info
      case @service.monitor
      when 0
        'Not monitored'
      when 1
        'Waiting'
      when 2
        'Initializing'
      when 3
        'Monitored'
      end
    end
    def monitor_mode
      case @service.monitormode
      when 0
        'Active'
      when 1
        'Passive'
      when 2
        'Manual'
      end
    end
    def pending_action
      case @service.pendingaction
      when 0
        'Ignore'
      when 1
        'Restart'
      when 2
        'Stop'
      when 3
        'Exec'
      when 4
        'Unmonitor'
      when 5
        'Start'
      when 6
        'Monitor'
      end
    end
    def hostname
      @service.port["hostname"]
    end
    def portnumber
      @service.port["portnumber"]
    end
    def request
      @service.port["request"]
    end
    def protocol
      @service.port["protocol"]
    end

    def is_host_service?
      @service.service_type == HOST_SERVICE_TYPE
    end
  end

end
