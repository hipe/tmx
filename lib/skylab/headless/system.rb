module Skylab::Headless

  module System
    # all in this file for now
  end

  module System::InstanceMethods
    # remember singletons are bad for testing

    # placeholder for etc yadda yadda the big dream, because probably
    # 'Open3' isn't cool anymore!

  protected

    def system
      @system ||= System::Client.new
    end
  end

  class System::Client

    def which exe_name
      if /\A[-a-z0-9_]+\z/i !~ exe_name
        raise "invalid name: #{ exe_name }"
      else
        out = nil
        Headless::Services::Open3.popen3 'which', exe_name do |_, sout, serr|
          if '' != ( err = serr.read )
            raise ::SystemCallError, "unexpected response from which - #{ err }"
          end
          out = sout.read.strip
        end
        '' == out ? nil : out
      end
    end

  protected

    # nothing is protected

  end
end
