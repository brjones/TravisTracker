module Monit
  module ServiceReader
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
      service_type == 'TYPE_SYSTEM'
    end
  end
end
