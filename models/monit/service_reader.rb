module Monit
  module ServiceReader
    def hostname
      @service.port["hostname"]
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
  end
end
