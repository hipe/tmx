module Skylab::TestSupport

  module Quickie

    class Plugins::Cover::Worker__

      def initialize adapter
        @adapter = adapter
        @y = @adapter.y
      end

      def execute

        @path_a = @adapter.services.get_test_path_array

        case @path_a.length <=> 1
        when -1 ; self.when_there_are_no_paths
        when  0 ; when_there_is_one_path
        when  1 ; when_there_are_multiple_paths
        else    ; self.wat
        end
      end

    private

      def when_there_is_one_path
        @path_s = @path_a.fetch 0
        @path_a = nil
        @lcbp_a = @path_s.split ::File::SEPARATOR
        @test_dir_idx = @lcbp_a.index( & Home_.lib_.match_test_dir_proc )
        if @test_dir_idx
          money_for_single_path
        else
          when_failed_to_find_test_directory
        end
      end

      def money_for_single_path
        @last_s = @lcbp_a.fetch( -1 )
        @tail_s = Home_.spec_rb
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

        _p = Home_.lib_.match_test_dir_proc

        @test_dir_idx = @lcbp_a.index( & _p )

        if @test_dir_idx
          when_found_test_directory
        else
          when_failed_to_find_test_directory
        end
      end

      def when_failed_to_find_test_directory
        @y << __say_failed_to_find
        UNABLE_
      end

      def __say_failed_to_find
        "(failed to find test directory - #{ @lcbp_a * ::File::SEPARATOR })"
      end

      def when_found_test_directory
        @lcbp_a[ @test_dir_idx, 1 ] = EMPTY_A_
        path_prefix = procure_any_pth_prefix_from_LCBP @lcbp_a * ::File::SEPARATOR
        path_prefix and start_service_with_path_prefix path_prefix
      end

      def procure_any_pth_prefix_from_LCBP longest_common_base_path

        path = ::File.expand_path longest_common_base_path
        tried_a = nil

        begin

          if ::File::SEPARATOR == path
            did_fail = true
            break
          end

          if ::File.directory? path
            break
          end

          if ::File.extname( path ).length.zero?

            corefile_as_nipple = "#{ path }#{ Autoloader_::EXTNAME }"

            if ::File.exist? corefile_as_nipple
              break
            end

            ( tried_a ||= [] ).push corefile_as_nipple

            corefile_as_corefile = ::File.join path, Autoloader_::CORE_FILE

            if ::File.exist? corefile_as_corefile
              break
            end

            tried_a.push corefile_as_corefile
          end

          path = ::File.dirname path

          redo
        end while nil

        if did_fail
          reprt_failure_to_find_business_path longest_common_base_path, tried_a
        else
          path
        end
      end

      def reprt_failure_to_find_business_path lcbp, tried_a
        @y << "failed to find business path from longest common base path - #{
          }#{ lcbp }"
        tried_a and reprt_tried_these_paths tried_a
        UNABLE_
      end

      def reprt_tried_these_paths tried_a

        p = Home_.lib_.system.new_pather.method :call

        _a = tried_a.reduce [] do | m, x |
          m.push p[ x ]
        end

        @y << "(there is no #{ _a * ', ' })" ; nil
      end

      def start_service_with_path_prefix path_prefix
        _io = resolve_stderr_IO
        Home_::Coverage_::Service.start _io, -> { path_prefix }
      end

      def resolve_stderr_IO
        @adapter.stderr
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
          res_a = [] ; path_a_a = path_a.map { |x| x.split ::File::SEPARATOR }
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
