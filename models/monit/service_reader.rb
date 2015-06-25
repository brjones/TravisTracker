module Monit


  module EventReader

  def monitored_types
    @monitored_types ||= ['TYPE_FILESYSTEM', 'TYPE_DIRECTORY', 'TYPE_FILE', 'TYPE_PROCESS', 'TYPE_HOST', 'TYPE_SYSTEM', 'TYPE_FIFO', 'TYPE_PROGRAM']
  end

  def success_msg_by_monitored_type
    @success_msg_by_monitored_type ||= ["Accessible", "Accessible", "Accessible", "Running", "Online with all services", "Running", "Accessible", "Status ok"]
  end

    def service_type
      monitored_types[@service.service_type.to_i]
    end

    def descriptions
      @descriptions ||= Hash[[
        ["Event_Action",     "Action done",             "Action done",                "Action done",              "Action done"],
        ["Event_Checksum",   "Checksum failed",         "Checksum succeeded",         "Checksum changed",         "Checksum not changed"],
        ["Event_Connection", "Connection failed",       "Connection succeeded",       "Connection changed",       "Connection not changed"],
        ["Event_Content",    "Content failed",          "Content succeeded",          "Content match",            "Content doesn't match"],
        ["Event_Data",       "Data access error",       "Data access succeeded",      "Data access changed",      "Data access not changed"],
        ["Event_Exec",       "Execution failed",        "Execution succeeded",        "Execution changed",        "Execution not changed"],
        ["Event_Fsflag,"     "Filesystem flags failed", "Filesystem flags succeeded", "Filesystem flags changed", "Filesystem flags not changed"],
        ["Event_Gid",        "GID failed",              "GID succeeded",              "GID changed",              "GID not changed"],
        ["Event_Heartbeat",  "Heartbeat failed",        "Heartbeat succeeded",        "Heartbeat changed",        "Heartbeat not changed"],
        ["Event_Icmp",       "Ping failed",             "Ping succeeded",             "Ping changed",             "Ping not changed"],
        ["Event_Instance",   "Monit instance failed",   "Monit instance succeeded",   "Monit instance changed",   "Monit instance not changed"],
        ["Event_Invalid",    "Invalid type",            "Type succeeded",             "Type changed",             "Type not changed"],
        ["Event_Nonexist",   "Does not exist",          "Exists",                     "Existence changed",        "Existence not changed"],
        ["Event_Permission", "Permission failed",       "Permission succeeded",       "Permission changed",       "Permission not changed"],
        ["Event_Pid",        "PID failed",              "PID succeeded",              "PID changed",              "PID not changed"],
        ["Event_PPid",       "PPID failed",             "PPID succeeded",             "PPID changed",             "PPID not changed"],
        ["Event_Resource",   "Resource limit matched",  "Resource limit succeeded",   "Resource limit changed",   "Resource limit not changed"],
        ["Event_Size",       "Size failed",             "Size succeeded",             "Size changed",             "Size not changed"],
        ["Event_Status",     "Status failed",           "Status succeeded",           "Status changed",           "Status not changed"],
        ["Event_Timeout",    "Timeout",                 "Timeout recovery",           "Timeout changed",          "Timeout not changed"],
        ["Event_Timestamp",  "Timestamp failed",        "Timestamp succeeded",        "Timestamp changed",        "Timestamp not changed"],
        ["Event_Uid",        "UID failed",              "UID succeeded",              "UID changed",              "UID not changed"],
        ["Event_Uptime",     "Uptime failed",           "Uptime succeeded",           "Uptime changed",           "Uptime not changed"],
        # Virtual events
        ["Event_Null",       "No Event",                "No Event",                   "No Event",                 "No Event"]
      ].map{|id, *args| [id, args]}]
    end

    def flags
      @flags ||= Hash[[
          #["Event_Null", 0x0],
          ["Event_Checksum", 0x1],
          ["Event_Resource", 0x2],
          ["Event_Timeout", 0x4],
          ["Event_Timestamp", 0x8],
          ["Event_Size", 0x10],
          ["Event_Connection", 0x20],
          ["Event_Permission", 0x40],
          ["Event_Uid", 0x80],
          ["Event_Gid", 0x100],
          ["Event_Nonexist", 0x200],
          ["Event_Invalid", 0x400],
          ["Event_Data", 0x800],
          ["Event_Exec", 0x1000],
          ["Event_Fsflag", 0x2000],
          ["Event_Icmp", 0x4000],
          ["Event_Content", 0x8000],
          ["Event_Instance", 0x10000],
          ["Event_Action", 0x20000],
          ["Event_Pid", 0x40000],
          ["Event_PPid", 0x80000],
          ["Event_Heartbeat", 0x100000],
          ["Event_Status", 0x200000],
          ["Event_Uptime", 0x400000],
          ["Event_All", 0x7FFFFFFF]
      ].map{|id, args| [id, args]}]
    end

    def state_description
      code = @service.status.to_i
      return success_msg_by_monitored_type[@service.service_type.to_i] if is_success_state?
      flag_id = flags.to_a.detect{|event_id, flag| (flag & code) != 0 }[0]
      return descriptions[flag_id][@service.status_hint.to_i]
    end

    def is_success_state?
      @service.status.to_i == 0
    end
  end

  module MonitorReader

    def monitor_info
      case @service.monitor.to_i
        when 0 then 'Not monitored'
        when 1 then 'Monitored'
        when 2 then 'Initializing'
        when 3 then 'Waiting'
      end
    end
    def monitor_mode
      case @service.monitormode.to_i
        when 0 then 'Active'
        when 1 then 'Passive'
        when 2 then 'Manual'
      end
    end
    def pending_action
      case @service.pendingaction.to_i
        when 0 then 'Ignore'
        when 1 then 'Restart'
        when 2 then 'Stop'
        when 3 then 'Exec'
        when 4 then 'Unmonitor'
        when 5 then 'Start'
        when 6 then 'Monitor'
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
      service_type == 'TYPE_SYSTEM'
    end
  end

  module ServiceReader
    include EventReader
    include MonitorReader
  end
end
