module Skylab::BeautySalon

  class CrazyTownMagnetics_::FileChanges_via_Path_and_Function_and_Selector < Common_::MagneticBySimpleModel

    begin

      def initialize
        super
      end

      attr_writer(
        :path,
        :code_selector,
        :replacement_function,
        :filesystem,
        :listener,
      )

      def execute
        if __resolve_sexp
          __money
        end
      end

      def __money

        _sexp = remove_instance_variable :@__sexp

        CrazyTownMagnetics_::TriggerEvents_via_Sexp_and_Hooks.call_by do |o|
          o.sexp = _sexp
          o.code_selector = @code_selector
          o.replacement_function = @replacement_function
          o.listener = @listener
        end
      end

      # -- B.

      def __resolve_sexp
        if __resolve_big_string
          __do_resolve_sexp
        end
      end

      def __do_resolve_sexp

        _RubyParser = Home_.lib_.ruby_parser

        # _parser = RubyParser.new.parse _file

        _parser = RubyParser::V24.new

        _big_string = remove_instance_variable :@__big_string

        _timeout_seconds = 5

        @__sexp = _parser.process _big_string, "(file: #{ @path })", _timeout_seconds
        ACHIEVED_
      end

      def __resolve_big_string
        if __resolve_open_filehandle
          __resolve_big_string_via_open_fileahandle
        end
      end

      def __resolve_big_string_via_open_fileahandle
        io = remove_instance_variable :@__upstream_IO
        big_string = io.read
        io.close
        @__big_string = big_string ; ACHIEVED_
      end

      def __resolve_open_filehandle
        @__upstream_IO = @filesystem.open @path
        ACHIEVED_
      rescue ::Errno::ENOENT, ::Errno::EISDIR => e  # #todo this might should happen at read not here (EISDIR)
        _exception e
      end

      # -- A.

      define_method :_exception, DEFINITION_FOR_THE_METHOD_CALLED_EXCEPTION_

    end
    # -

    # ==

    class FileChanges___

      def initialize path
        @path = path
      end

      def to_diff_body_line_stream__
        ::Kernel._OKAY
      end

      def xx

        _big_string = <<-O
          @@ -1,5 +1,5 @@
           module Xx
             def yy
          -    foo.shall resemble :hi
          +    expect( foo ).to resemble :hi
             end
           end
        O
        r = 10..-1
        scn = Home_.lib_.basic::String::LineStream_via_String[ _big_string ]
        Common_.stream do
          line = scn.gets
          if line
            line[ r ]
          end
        end
      end

      attr_reader(
        :path,
      )
    end

    # ==
    # ==
  end
end
# #born.
