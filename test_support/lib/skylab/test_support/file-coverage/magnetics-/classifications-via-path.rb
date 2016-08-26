module Skylab::TestSupport

  module FileCoverage

    class Magnetics_::Classifications_via_Path < Common_::Actor::Dyadic

      def initialize td, path, & p
        @on_event_selectively = p
        @path = path
        @test_dir = td
      end

      def execute
        ok = __resolve_stat
        ok &&= __via_stat_determine_shape
        ok && __init_testiness
        ok &&= __determine_rootiness
        ok && __flush
      end

      def __resolve_stat
        @stat = ::File.stat @path
        ACHIEVED_
      rescue ::Errno::ENOENT => e
        __when_noent e
      end

      def __when_noent e

        @on_event_selectively.call :error, :resource_not_found do

          Common_::Event.wrap.exception e,
            :path_hack, :terminal_channel_i, :resource_not_found
        end
      end

      def __via_stat_determine_shape
        meth = :"__when_ftype_is__#{ @stat.ftype }__"
        if respond_to? meth
          send meth
        else
          self.__DO_ME_when_strange_ftype
        end
      end

      def __when_ftype_is__file__
        @shape_symbol = :file
        ACHIEVED_
      end

      def __when_ftype_is__directory__
        @shape_symbol = :directory
        ACHIEVED_
      end

      def __init_testiness
        _ = Home_.lib_.basic::Pathname::Path_matches_directory[ @path, @test_dir ]
        @testiness_symbol = _ ? :test : :asset
        NIL
      end

      def __determine_rootiness

        @rootiness_symbol = if :directory == @shape_symbol
          _is_root = if :test == @testiness_symbol
            @test_dir == @path
          else
            ::File.dirname( @test_dir ) == @path
          end
          _is_root ? :root : :non_root
        end
        ACHIEVED_
      end

      def __flush
        Classifications___[ @testiness_symbol, @shape_symbol, @rootiness_symbol ]
      end

      class Classifications___

        class << self
          alias_method :[], :new
        end  # >>

        def initialize te, sh, ro
          @rootiness = ro
          @shape = sh
          @testiness = te
        end

        def difference_against t_i, s_i, r_i
          d_x_a = nil
          if @testiness != t_i
            ( d_x_a ||= [] ).push [ :testiness, @testiness, t_i ]
          end
          if @shape != s_i
            ( d_x_a ||= [] ).push [ :shape, @shape, s_i ]
          end
          if @rootiness != r_i
            ( d_x_a ||= [] ).push [ :rootiness, @rootiness, s_i ]
          end
          if d_x_a
            Difference___.new d_x_a
          end
        end

        attr_reader(
          :rootiness,
          :shape,
          :testiness,
        )
      end

      class Difference___
        def initialize d_x_a
          @d_x_a = d_x_a
        end
        def description
          "difference: #{ @d_x_a.inspect }"
        end
      end

      FILE_SEPARATOR_BYTE_ = ::File::SEPARATOR.getbyte 0
    end
  end
end
