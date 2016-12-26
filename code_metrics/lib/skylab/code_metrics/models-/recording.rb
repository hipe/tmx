module Skylab::CodeMetrics

  module Models_::Recording

    class ByFile

      def initialize path, svcs
        @__path = path
        @__system_services = svcs
      end

      def to_event_tuple_stream
        self._CODE_SKETCH__needs_coverage_add_that_method_to_system_services__
        p = nil ; io = nil
        main = -> do
          line = io.gets
          if line
            Tuple_via_line__[ line ]
          else
            io.close
            p = EMPTY_P_ ; NOTHING_
          end
        end
        p = -> do
          io = @__system_services.open_file_read_only @__path
          p = main
          p[]
        end
        Common_.stream do
          p[]
        end
      end
    end

    class ByArray

      def initialize a
        @__array = a
      end

      def to_event_tuple_stream
        path_cache = {}
        Stream_.call @__array do |line|
          Tuple_via_line__[ line, path_cache ]
        end
      end
    end

    # ==

    class Tuple_via_line__ < Common_::Actor::Dyadic

      def initialize line, pc, & p
        @listener = p
        @path_cache = pc
        @string_scanner = ::StringScanner.new line
      end

      def execute
        __parse_lineno && __parse_event && __parse_module && __parse_path and
        __finish
      end

      def __parse_lineno
        @string_scanner.skip ONE_OR_MORE_SPACE_RX__
        _parse LINENO___
      end

      def __parse_event
        _parse_one_or_more_white and _parse EVENT___
      end

      def __parse_module
        _parse_one_or_more_white and _parse MODULE___
      end

      def __parse_path
        _parse_one_or_more_white and _parse PATH___
      end

      def __finish
        _parse NEWLINE___ and _parse END_OF_STRING___ and __flush
      end

      def _parse_one_or_more_white
        _parse ONE_OR_MORE_SPACE___
      end

      def _parse which
        kn = which.parse self
        if kn
          ivar = which.ivar
          if ivar
            instance_variable_set which.ivar, kn.value_x
          end
          ACHIEVED_
        end
      end

      def __flush
        Tuple___.new(
          remove_instance_variable( :@lineno ),
          remove_instance_variable( :@event_symbol ),
          remove_instance_variable( :@qualified_const_symbol ),
          remove_instance_variable( :@path ),
        )
      end

      attr_reader(
        :listener,
        :path_cache,
        :string_scanner,
      )
    end

    # ==

    class Tuple___

      def initialize d, sym, qcs, path
        @event_symbol = sym
        @lineno = d
        @path = path
        @qualified_const_symbol = qcs
      end

      attr_reader(
        :event_symbol,
        :lineno,
        :path,
        :qualified_const_symbol,
      )
    end

    # ==

    class RegexpBased__ < ::Module

      def initialize rx, ivar=nil, & p

        if ivar
          @__normalize = p || Normalize_normally___
          @_parse = :__parse_for_keeps
          @ivar = ivar
        else
          block_given? and raise ::ArgumentError
          @_parse = :__parse_for_skips
        end

        @regexp = rx
      end
    end  # will re-open

    Normalize_normally___ = -> s do
      Common_::Known_Known[ s ]
    end

    # --

    ONE_OR_MORE_SPACE_RX__ = %r([ ]+)

    ONE_OR_MORE_SPACE___ = RegexpBased__.new ONE_OR_MORE_SPACE_RX__

    LINENO___ = RegexpBased__.new %r(\d+), :@lineno do |s|
      Common_::Known_Known[ s.to_i ]
    end

    which_event = {
      class: Common_::Known_Known[ :class ],
      end: Common_::Known_Known[ :end ],
    }

    EVENT___ = RegexpBased__.new %r(class|end), :@event_symbol do |s|
      which_event.fetch s.intern
    end

    c = '[A-Z][a-zA-Z0-9_]*'
    _rx = %r(#{ c }(?: :: #{ c })*)x
    MODULE___ = RegexpBased__.new _rx, :@qualified_const_symbol do |s|
      Common_::Known_Known[ s.intern ]
    end

    PATH___ = RegexpBased__.new %r(/[^[:space:]]+), :@path do |s, scan|
      scan.path_cache.fetch s do
        x =  Common_::Known_Known[ s.freeze ]
        scan.path_cache[ s ] = x
        x
      end
    end

    NEWLINE___ = RegexpBased__.new %r(\n)

    END_OF_STRING___ = RegexpBased__.new %r(\z)  # hm..

    # --

    class RegexpBased__ < ::Module

      def parse scan
        send @_parse, scan
      end

      def __parse_for_keeps scan
        s = scan.string_scanner.scan @regexp
        if s
          @__normalize[ s, scan ]
        else
          _whine scan
        end
      end

      def __parse_for_skips scan
        _yes = scan.string_scanner.skip @regexp
        if _yes
          ACHIEVED_
        else
          _whine scan
        end
      end

      def _whine scan
        self._CODE_SKETCH__needs_coverage_might_be_OK_

        _scn = scan.string_scanner
        _moniker = __name_as_human

        scan.listener.call :error, :expression, :unmarshalling_error do |y|
          y << "expected #{ _moniker } near #{ _scn.rest[ 0, 15 ].inspect }"
        end
        UNABLE_
      end

      def __name_as_human
        @___name_as_human ||= __derive_name_as_human
      end

      def __derive_name_as_human
        _ = name.split( CONST_SEP_ ).last
        _.gsub( %r(_+\z), EMPTY_S_ ).gsub( UNDERSCORE_, SPACE_ ).downcase
      end

      attr_reader(
        :ivar,
      )
    end

    # ==

    Home_.lib_.string_scanner

    # ==
  end
end
# #born: for mondrian
