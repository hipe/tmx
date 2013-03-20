require_relative '../test-support'
require 'skylab/face/test/cli/test-support'

module Skylab::FileMetrics::TestSupport::CLI

  ::Skylab::Face::TestSupport::CLI[ self ]  # KRAY
  ::Skylab::FileMetrics::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module ModuleMethods

    include CONSTANTS

    def sandbox_module
      # (we aren't in the business of producing modules (we aren't DSL-y, we
      # are a subproduct) so we don't need a sandbox module to populate with
      # generated nerks. Make sure we don't accidentally use the auxiliary
      # version of this method because it would populate a sandbox in a
      # strange module (the alternative would be too overwrought).
    end

    def client_class
      FileMetrics::CLI
    end

    extend MetaHell::DSL_DSL

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
      define_method :expect_integer do |x|
        if rx =~ x then $~[0].to_i else
          fail "expecting this to look like integer - #{ x.inspect }"
        end
      end
    end.call

    -> do  # `expect_percent`
      rx = /\A\d{1,3}\.\d\d%\z/
      define_method :expect_percent do |x, pct_f=nil|
        if rx !~ x then
          fail "expecting this to look like percent - #{ x.inspect }"
        elsif pct_f
          f = $~[0].to_f
          f.should eql( pct_f )
          nil
        end
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
      end
    end.call
  end
end
