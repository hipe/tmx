module Skylab::TMX

  class Operations_::Reports

    class << self
      alias_method :begin, :new
      undef_method :new
    end  # >>

    # -

      def initialize & p
        @_emit = p
      end

      attr_writer(
        :argument_scanner,
      )

      def execute

        @_name_box = Report_names_box___[]

        if @argument_scanner.no_unparsed_exists
          __list
        elsif __find_name
          __retrieve
        else
          __when_not_found
        end
      end

      def __list
        @_name_box.to_value_stream
      end

      def __find_name

        _sym = @argument_scanner.head_as_normal_symbol

        _store :@_name, @_name_box.h_[ _sym ]
      end

      def __when_not_found

        _name = @argument_scanner.head_as_agnostic
        _box = @_name_box

        @_emit.call :error, :expression, :parse_error, :unrecognized_report do |y|

          y << "unrecognized report: #{ say_strange_arguments_head_ _name }"

          _p = method :say_arguments_head_

          _buffer = _box.to_value_stream.join_into_with_by "", ", ", & _p

          y << "available reports: (#{ _buffer })"
        end

        UNABLE_
      end

      def __retrieve

        _const = @_name.as_camelcase_const_string

        _report_class = Home_::Reports_.const_get _const, false

        _ = _report_class.new( & @_emit ).execute
        _  # #todo
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -

    Report_names_box___ = Lazy_.call do
      Box_via_autoloaderized_module_[ Home_::Reports_ ]
    end

    # ==
  end
end
