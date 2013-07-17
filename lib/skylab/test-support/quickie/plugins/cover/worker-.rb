module Skylab::TestSupport

  module Quickie

    class Plugins::Cover::Worker_

      def initialize svc
        @svc = svc
        @y = @svc.y
      end

      def execute
        path_a = @svc.get_test_path_a
        a = Longest_common_base_path_[ path_a ]
        if a.length.zero?
          @y << "(found no longest common basepath among #{ path_a.length } #{
            }paths - can't generate coverage.)"
          @y << "(paths were: #{ path_a * ', ' })"
          false
        elsif ! (( idx = a.index( & Match_test_dir_ ) ))
          @y << "(failed to find test directory - #{ a * SEP_ })"
          false
        else
          a[ idx, 1 ] = MetaHell::EMPTY_A_
          path_prefix = ::Pathname.new( a * SEP_ ).expand_path.to_s
          _omg_stderr = @svc._svc._host._svc.infostream
          TestSupport::Coverage::Service.start _omg_stderr, -> { path_prefix }
        end
      end

      Match_test_dir_ = -> do
        require 'skylab/cov-tree/constants'  # special case, avoid loading core
        ::Skylab::CovTree::Constants::TEST_DIR_NAME_A.method :include?
      end.call

      SEP_ = '/'.freeze

      Longest_common_base_path_ = -> path_a do  # because we are covering that
        res_a = []
        if path_a.length.nonzero?
          path_a_a = path_a.map { |x| x.split SEP_ }
          while true
            like = path_a_a.fetch( 0 ).shift or break
            path_a_a[ 1 .. -1 ].each do |p_a|
              otr = p_a.shift
              if ! otr || like != otr
                like = nil
                break
              end
            end
            like or break
            res_a << like
          end
        end
        res_a
      end
    end
  end
end
