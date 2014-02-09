require_relative '../test-support'
require 'skylab/face/test/cli/test-support'

module Skylab::FileMetrics::TestSupport::CLI

  ::Skylab::FileMetrics::Face_::TestSupport::CLI[ self ]  # KRAY
  ::Skylab::FileMetrics::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS

  Lib_ = Lib_

  extend TestSupport::Quickie

  module ModuleMethods

    include CONSTANTS

    def client_class
      FileMetrics::CLI
    end

  end

  module InstanceMethods

    include CONSTANTS

    def program_name
      'fm'
    end

    def headers_hack line
      cels_hack( line ).map { |x| x.downcase.gsub( ' ', '_' ).intern }
    end

    def cels_hack line
      line.strip.split( / {2,}/ )
    end

    -> do  # `expect_integer`
      rx = /\A\d+\z/
      define_method :expect_integer do |x, range=nil|
        if rx =~ x then $~[0].to_i else
          fail "expecting this to look like integer - #{ x.inspect }"
        end
        if range
          if ! range.include? x.to_i
            fail "expecting integer #{ x.to_i } to be btwn #{ range }"
          end
        end
        nil
      end
    end.call

    -> do  # `expect_percent`
      rx = /\A\d{1,3}\.\d\d%\z/
      define_method :expect_percent do |x, pct_p=nil|
        if rx !~ x then
          fail "expecting this to look like percent - #{ x.inspect }"
        elsif pct_p
          f = $~[0].to_f
          f.should eql( pct_p )
        end
        nil
      end
    end.call

    -> do  # `expect_pluses`
      rx = /\A\++\z/
      define_method :expect_pluses do |x, range|
        if rx !~ x then
          fail "expecting this to look like pluses - #{ x.inspect }"
        elsif ! range.include? x.length
          fail "expecting number of pluses #{ x.length } to be btwn #{ range }"
        end
        nil
      end
    end.call
  end
end
