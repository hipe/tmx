#!/usr/bin/env ruby -w

require_relative '../../../test-support'

module Skylab::System::TestSupport

  stderr = ::Skylab::TestSupport.debug_IO

  _from_dir = ::File.join TS_.dir_path, 'io', 'select', 'visual-'

  Home_.lib_.file_utils.cd _from_dir, verbose: true do

    select = Home_::IO.select.new
    select.timeout_seconds = 0.3

    Home_.lib_.open3.popen3 'sh' do |sin, sout, serr, t|

      sin.puts 'source tmp.sh'
      sin.close

      select.on sout do |ln|
        stderr.puts "SOUT:-->#{ ln.inspect }<--"
      end

      select.on serr do |ln|
        stderr.puts "SERR:-->#{ ln.inspect }<--"
      end

      beat = 0
      select.heartbeat 0.4 do
        stderr.puts "(beat #{ beat += 1 })"
      end

      loop do
        bytes = select.select
        if 0 == bytes
          break
        end
      end
    end
  end
end
