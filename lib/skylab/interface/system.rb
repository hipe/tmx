require 'open3'

module Skylab::Interface
  module System
    extend Skylab::Autoloader
    # placeholder for etc yadda yadda the big dream, because probably
    # 'Open3' isn't cool anymore!
    def sys
      @system_interface ||= System::Interface.new
    end
  end
  class System::Interface
    def which exe_name
      /\A[-a-z]+\z/i =~ exe_name or fail("invalid name: #{exe_name}")
      out = err = nil
      xx = Open3.popen3('which', exe_name) do |sin, sout, serr|
        (err = serr.read) == '' or fail("no: #{err.inspect}")
        out = sout.read.strip
      end
      '' == out ? nil : out
    end
  end
end

