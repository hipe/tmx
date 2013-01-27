#!/usr/bin/env ruby -w

require_relative '../test-support'


module Skylab::Headless::TestSupport::IO::Upstream::Select

  from_dir = Select_TestSupport.dir_pathname.join( 'visual' ).to_s
  Headless::Services::FileUtils.cd from_dir, verbose: true do

    select = Headless::IO::Upstream::Select.new
    select.timeout_seconds = 0.3
    select.line[:stderr] = -> s { $stderr.puts "SERR:-->#{ s.inspect }<--" }
    select.line[:stdout] = -> s { $stderr.puts "SOUT:-->#{ s.inspect }<--" }

    Headless::Services::Open4.open4 'sh' do |pid, sin, sout, serr|
      sin.puts 'source tmp.sh'
      sin.close
      select.stream[:stdout] = sout
      select.stream[:stderr] = serr
      loop do
        bytes = select.select
        if 0 == bytes
          break
        end
      end
    end
  end
end
