require 'open3'

module Skylab::Interface
  module System  # [#001] - these belong in i.m's
    extend Autoloader
    # placeholder for etc yadda yadda the big dream, because probably
    # 'Open3' isn't cool anymore!
    def sys
      @system_interface ||= System::Interface.new
    end
  end

  class System::Interface
    def which exe_name
      /\A[-a-z]+\z/i =~ exe_name or fail "invalid name: #{ exe_name }"
      out = err = nil
      ::Open3.popen3 'which', exe_name do |sin, sout, serr|
        err = serr.read
        if '' != err
          fail "no: #{ err.inspect }"
        end
        out = sout.read.strip
      end
      '' == out ? nil : out
    end
  end
end
