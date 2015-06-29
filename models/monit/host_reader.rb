module Monit
  module HostReader
    def is_dead?
      false
    end

    def load_avg1
      @service.system["load"]["avg01"]
    end

      def load_avg5
      @service.system["load"]["avg05"]
    end


    def load_avg15
      @service.system["load"]["avg15"]
    end


    def cpu_user
      @service.system["cpu"]["user"]
    end

    def cpu_system
      @service.system["cpu"]["system"]
    end

    def memory_percent
      @service.system["memory"]["percent"]
    end

    def memory_kilobyte
      @service.system["memory"]["kilobyte"]
    end

    def kilobyte_to_gigabyte(kilobyte)
      "%0.2f" % ((kilobyte.to_f/1024)/1024)
    end

    def swap_percent
      @service.system["swap"]["percent"]
    end

    def swap_kilobyte
      @service.system["swap"]["kilobyte"]
    end
  end
end
