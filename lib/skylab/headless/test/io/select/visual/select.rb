#!/usr/bin/env ruby -w

require_relative '../test-support'

module Skylab::Headless::TestSupport::IO::Select

  stderr = ::Skylab::TestSupport.debug_IO

  from_dir = TS_.dir_pathname.join( 'visual' ).to_s

  Headless_::Library_::FileUtils.cd from_dir, verbose: true do

    select = Headless_::IO.select.new
    select.timeout_seconds = 0.3

    Headless_::Library_::Open4.open4 'sh' do |pid, sin, sout, serr|
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
