class ServicePresenter

  include Monit::Reader

  UNSPECIFIED_PROCESS = 'general'
  @@EXCLUDING_LIST = []

  attr_reader :environment, :application, :process

  def self.add_name_to_token_excluding_list(name)
    @@EXCLUDING_LIST.push(name)
  end

  def host_sanitize_name(name)
    @@EXCLUDING_LIST.each do |excluding_name|
      name=name.gsub(excluding_name, excluding_name.gsub(/_/,"&nbsp;"))
    end
    name
  end

  def initialize(service)
    @service = service

    if is_host_service?
      class << self
        include Monit::HostReader
      end
    else
      class << self
        include Monit::ServiceReader
      end
    end


    name=host_sanitize_name(service.name)
    name_array = name.split('_').map{|s| s.split('.')}.flatten
    name_array << UNSPECIFIED_PROCESS if name_array.length < 3
    name_array.unshift(UNSPECIIFED_ENVIRONMENT) if name_array.length < 3
    @environment = name_array.shift.humanize
    @application = name_array.shift.humanize
    @process     = name_array.join(' ').humanize
  end

  def is_host_service?
    service_type == 'TYPE_SYSTEM'
  end

  def name
    if service_type=="TYPE_PROCESS"
      "#{@service.name} [#{protocol}] @:#{portnumber}"
    else
      @service.name
    end
  end

  def description
    "#{state_description}"
  end

  def monitoring_description
    "#{monitor_info} #{monitor_mode} #{pending_action}"
  end

  def protocol
    return '' if @service.port.nil?
    if @service.port.kind_of? Array
      return @service.port[0]['protocol']
    end
    @service.port['protocol']
  end
  def portnumber
    return '' if @service.port.nil?
    if @service.port.kind_of? Array
      return @service.port[0]['portnumber']
    end
    @service.port['portnumber']
  end
  def hostname
    return '' if @service.port.nil?
    if @service.port.kind_of? Array
      return @service.port[0]['hostname']
    end
    @service.port['hostname']
  end

  def service_info
    "[#{protocol}] at port #{portnumber}"
  end

  def state
    is_success_state? ? 'success' : 'danger'
  end

end
