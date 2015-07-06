class ServicePresenter

  include Monit::ServiceReader
  include Monit::HostReader

  UNSPECIFIED_PROCESS = 'general'

  attr_reader :environment, :application, :process
  def initialize(service)
    @service = service
    name = service.name.gsub(/next_release/,"nextrelease")
    name_array = name.split('_').map{|s| s.split('.')}.flatten
    name_array << UNSPECIFIED_PROCESS if name_array.length < 3
    #binding.pry
    name_array.unshift(UNSPECIIFED_ENVIRONMENT) if name_array.length < 3
    @environment = name_array.shift.humanize
    @application = name_array.shift.humanize
    @process     = name_array.join(' ').humanize
  end


  def name
    #service.description
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
