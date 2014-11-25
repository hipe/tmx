module Skylab::TestSupport

  module Quickie

    self::Front__.class

    class Plugins::Cover::Worker__

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
        @lcbp_a = @path_s.split( SEP_ )
        @test_dir_idx = @lcbp_a.index( & QuicLib_::Match_test_dir_proc[] )
        if @test_dir_idx
          money_for_single_path
        else
          when_failed_to_find_test_directory
        end
      end

      def money_for_single_path
        @last_s = @lcbp_a.fetch( -1 )
        @tail_s = TestSupport_.spec_rb
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
        UNABLE_
      end
      UNABLE_ = false

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
        UNABLE_
      end

      def when_lcbp_is_nonzero_in_length
        if ( @test_dir_idx = @lcbp_a.index( & QuicLib_::Match_test_dir_proc[] ))
          when_found_test_directory
        else
          when_failed_to_find_test_directory
        end
      end

      def when_failed_to_find_test_directory
        @y << "(failed to find test directory - #{ @lcbp_a * SEP_ })"
        UNABLE_
      end

      def when_found_test_directory
        @lcbp_a[ @test_dir_idx, 1 ] = EMPTY_A_
        path_prefix = procure_any_pth_prefix_from_LCBP @lcbp_a * SEP_
        path_prefix and start_service_with_path_prefix path_prefix
      end

      def procure_any_pth_prefix_from_LCBP longest_common_base_path
        pn = ::Pathname.new( longest_common_base_path ).expand_path
        tried_a = nil
        begin
          SEP_ == pn.instance_variable_get( :@path ) and break( did_fail = true )
          pn.directory? and break
          (( pn_ = pn.sub_ext Autoloader_::EXTNAME )).exist? and break
          (( tried_a ||= [] )) << pn_
          pn = pn.dirname
          redo
        end while true
        if did_fail
          reprt_failure_to_find_business_path longest_common_base_path, tried_a
        else
          pn.to_s
        end
      end

      def reprt_failure_to_find_business_path lcbp, tried_a
        @y << "failed to find business path from longest common base path - #{
          }#{ lcbp }"
        tried_a and reprt_tried_these_paths tried_a
        UNABLE_
      end

      def reprt_tried_these_paths tried_a
        _a = tried_a.reduce [] do |m, x|
          m << QuicLib_::Pretty_path[ x ]
        end
        @y << "(there is no #{ _a * ', ' })" ; nil
      end

      def start_service_with_path_prefix path_prefix
        _io = resolve_stderr_IO
        TestSupport_::Coverage::Service.start _io, -> { path_prefix }
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
          res_a = [] ; path_a_a = path_a.map { |x| x.split SEP_ }
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
