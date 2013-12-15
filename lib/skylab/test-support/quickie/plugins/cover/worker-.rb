module Skylab::TestSupport

  module Quickie

    class Plugins::Cover::Worker_

      def initialize svc
        @svc = svc
        @y = @svc.y
      end

      def execute
        @path_a = @svc.get_test_path_a
        case @path_a.length <=> 1
        when -1 ; self.when_there_are_no_paths
        when  0 ; when_there_is_one_path
        when  1 ; when_there_are_multiple_paths
        else    ; self.wat
        end
      end

    private

      def when_there_is_one_path
        @path_s = @path_a.fetch 0 ; @path_a = nil
        @lcbp_a = @path_s.split( SEP__ )
        @test_dir_idx = @lcbp_a.index( & Match_test_dir__ )
        if @test_dir_idx
          money_for_single_path
        else
          when_failed_to_find_test_directory
        end
      end

      def money_for_single_path
        @last_s = @lcbp_a.fetch( -1 )
        @tail_s = TestSupport::FUN::Spec_rb[]
        @rx = /#{ ::Regexp.escape @tail_s }\z/
        if @rx !~ @tail_s
          when_tail_part_did_not_match
        else
          @lcbp_a.pop
          when_found_test_directory
        end
      end

      def when_tail_part_did_not_match
        @y << "(expected \"#{ @last_s }\" to end in \"#{ @tail_s }\" - #{
          }can't generate coverage for path - #{ @path_s })"
        FAILED__
      end
      FAILED__ = false

      def when_there_are_multiple_paths
        @lcbp_a = Longest_common_base_path__[ @path_a ]
        if @lcbp_a.length.zero?
          when_lcbp_is_zero_in_length
        else
          when_lcbp_is_nonzero_in_length
        end
      end

      def when_lcbp_is_zero_in_length
        @y << "(found no longest common basepath among #{ @path_a.length } #{
          }paths - can't generate coverage.)"
        @y << "(paths were: #{ @path_a * ', ' })"
        FAILED__
      end

      def when_lcbp_is_nonzero_in_length
        if (( @test_dir_idx = @lcbp_a.index( & Match_test_dir__ ) ))
          when_found_test_directory
        else
          when_failed_to_find_test_directory
        end
      end

      Match_test_dir__ = -> do
        require 'skylab/sub-tree/constants'  # special case, avoid loading core
        ::Skylab::SubTree::Constants::TEST_DIR_NAME_A.method :include?
      end.call

      def when_failed_to_find_test_directory
        @y << "(failed to find test directory - #{ @lcbp_a * SEP__ })"
        FAILED__
      end
      SEP__ = '/'.freeze

      def when_found_test_directory
        @lcbp_a[ @test_dir_idx, 1 ] = MetaHell::EMPTY_A_
        _path_prefix = ::Pathname.new( @lcbp_a * SEP__ ).expand_path.to_s
        start_service_with_path_prefix _path_prefix
      end

      def start_service_with_path_prefix path_prefix
        _io = resolve_stderr_IO
        TestSupport::Coverage::Service.start _io, -> { path_prefix }
      end

      def resolve_stderr_IO
        @svc._svc._host._svc.infostream  # #todo
      end

      Longest_common_base_path__ = -> do  # becase we are covering that

        others_p = -> path_a_a, res_a do
          -> s do
            all_same = true
            path_a_a[ 1 .. -1 ].each do |x_a|
              otr = x_a.shift
              otr or break( all_same = nil )
              s == otr or break( all_same = nil )
            end
            if all_same
              res_a << s ; true
            end
          end
        end

        visitor_p = -> path_a_a, res_a do
          others = others_p[ path_a_a, res_a ]
          -> do
            s = path_a_a.fetch( 0 ).shift
            s and others[ s ]
          end
        end

        nonzero = -> path_a do
          res_a = [] ; path_a_a = path_a.map { |x| x.split SEP__ }
          visit = visitor_p[ path_a_a, res_a ]
          nil while visit[]
          res_a
        end

        -> path_a do
          path_a.length.zero? ? [] : nonzero[ path_a ]
        end
      end.call
    end
  end
end
