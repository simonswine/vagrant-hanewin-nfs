require 'open3'

module VagrantPlugins
  module VagrantHanewinNfs 
    # Class reprents a windows service and allows
    # to control this service via the sc command
    class WindowsService

      def initialize(name)
        @name = name
        @sc_cmd = "sc"
        @logger = Log4r::Logger.new("vagrant::hosts::windows")

      end

      # Run sc command
      def run_cmd(command)
        cmd = "#{@sc_cmd} #{command} \"#{@name}\""
        @logger.debug "WindowsServer run cmd #{cmd}"
        stdout, stderr, status = Open3.capture3(cmd)

        # Get allowed exit status
        if command == 'start'
          allowed_exitstatus = [0, 32]
        elsif command == 'stop'
          allowed_exitstatus = [0, 38]
        else
          allowed_exitstatus = [0]
        end

        # Check exitstatus
        if allowed_exitstatus.include? status.exitstatus
          return stdout
        elsif status.exitstatus == 5
          raise "Permission denied"
        elsif [36,103].include? status.exitstatus
          raise "Service #{@name} not found"
        else
          raise "Unknown return code #{status.exitstatus}: #{stdout}"    
        end
      end

      def start
        run_cmd('start')
        wait_for_status('RUNNING')
      end

      def stop
        run_cmd('stop')
        wait_for_status('STOPPED')
      end

      def restart
        stop
        start
      end

      def status
        output = run_cmd('query')
        # Match state
        status = /STATE[\s:]+\d+\s+([\S]+)/.match(output)
        if status.nil?
          return nil
        else
          return status[1]
        end
      end

      # Waits until service has desired state
      def wait_for_status(state,sleep_duration=0.1, max_tries=20)
        try = 0
        while status != state do
          try += 1
          sleep(sleep_duration)
          if try >= max_tries 
            raise "Error waiting for state '#{state}'"
          end
        end
      end
    end
  end
end
