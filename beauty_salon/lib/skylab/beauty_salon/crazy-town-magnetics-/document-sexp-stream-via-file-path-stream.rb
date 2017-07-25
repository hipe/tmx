module Skylab::BeautySalon

  class CrazyTownMagnetics_::DocumentSexpStream_via_FilePathStream < Common_::SimpleModel

    # mainly, convert a stream of paths to a stream of "potential sexps":
    #
    #   - insulate the rest of our system from having to think about the
    #     lower-level issue that can happen with file IO (file not found, etc)
    #
    #   - insulate the rest of our system from knowing anything about how
    #     to interface with the external ruby parsing library.
    #
    # using the main "attributes" (methods) of the subject will lead to
    # the stream it is constructed with to be consumed. as such (in part
    # as a sanity check) the subject is stateful and its main attribute
    # methods are *not* re-entrant.

    # -

      class << self
        alias_method :call_by, :define
      end  # >>

      def initialize
        yield self
        __init_potential_sexp_stream
        __init_ruby_parser
      end

      attr_writer(
        :file_path_upstream,
        :filesystem,
        :listener,
      )

      def line_stream_via_file_chunked_functional_definition  # NOT re-entrant

        # crazily, we need to have this line caching thing instantiated
        # before we even evaluate our defition (because our event hooks
        # rely on closure scope)

        lc = CrazyTownMagnetics_::LineStream_via_DocumentSexpStream::StatefulLineCachingThing.new

        hooks = CrazyTownMagnetics_::Hooks_via_HooksDefinition.new do |o|
          yield lc.line_yielder, o
        end

        _etc_st = remove_instance_variable :@__potential_sexp_stream

        CrazyTownMagnetics_::LineStream_via_DocumentSexpStream.call_by do |o|
          o.hooks = hooks
          o.per_file_line_cache = lc.line_cache
          o.potential_sexp_stream = _etc_st
        end
      end

      def __init_potential_sexp_stream

        proto = PotentialSexp___.new self

        _file_path_st = remove_instance_variable :@file_path_upstream

        @__potential_sexp_stream = _file_path_st.map_by do |path|

          proto.dup.__init_new_instance_ path
        end

        NIL
      end
    # -  # (will re-open)

    # ==

    class PotentialSexp___

      # wrap a filesystem path (that perhaps has no or an invalid referrant)
      # such that statefully & lazily it attempts to evaluate a sexp value
      # (it tries to parse the file that the path ostensibly points to).
      #
      # consider the errors that might occur:
      #
      #   - the file could be not found or the path could be otherwise
      #     unable to be opened as a file
      #
      #   - there could be an error parsing the file (e.g we are parsing it
      #     against the wrong version of ruby, e.g the parser has a
      #     discrepancy with MRI, e.g the file has a plain old syntax error.)
      #
      # only the first time the `sexp` attribute is accesses will the file
      # be attempted to be parsed, delegating to the external parsing
      # resources (which wrap a listener) the emission of any such errors
      # that might occur.
      #
      # this `sexp` attribute value will be false-ish IFF any such errors
      # occurred.
      #
      # any subsequent time this attribute value is read, the same result
      # will occur (without any side-effected emissions that may have
      # occurred before): the result from the first time is frozen into
      # the subject.

      # possible wishlist: if we really needed to, we could freeze the any
      # emitted emissions into the subject as recordings - but why?

      def initialize rsx
        # (as prototype)
        @sexp = :__sexp_initially
        @__parsing_resources = rsx
        freeze
      end

      def __init_new_instance_ path
        @path = path ; self
      end

      def sexp
        send @sexp
      end

      def __sexp_initially
        @sexp = :__sexp_subsequently
        _rsx = remove_instance_variable :@__parsing_resources
        _xx = _rsx.__sexp_via_path_ @path
        @__mixed_sexp_value = _xx
        freeze
        send @sexp
      end

      def __sexp_subsequently
        @__mixed_sexp_value
      end

      attr_reader(
        :path,
      )
    end

    # ==

    # - # (re-open in service of potential sexp)

      def __sexp_via_path_ path
        io = __open_filehandle_via_path path
        if io
          big_s = __big_string_via_open_filehandle io
          if big_s
            __sexp_via_big_string big_s, path
          end
        end
      end

      # -- interface with 'ruby_parser' (COMPREHENSIVE)

      def __sexp_via_big_string big_s, path

        _label = if path
          "(file: #{ path })"
        else
          "(some big string)"  # ..
        end

        _sexp = @__ruby_parser.process big_s, _label, @__timeout_seconds  # ..

        _sexp  # hi.
      end

      def __init_ruby_parser

        _RubyParser = Home_.lib_.ruby_parser  # :#spot-1.1
        @__ruby_parser = ::RubyParser::V24.new  # ..
        # parser = RubyParser.new.parse _file

        @__timeout_seconds = 5  # or whatever. longer if step-debugging :/

        NIL
      end

      # -- interface with the filesystem (COMPREHENSIVE)

      def __big_string_via_open_filehandle io
        big_string = io.read
        io.close
        big_string
      end

      def __open_filehandle_via_path path
        @filesystem.open path
      rescue ::Errno::ENOENT, ::Errno::EISDIR => e  # #todo this might should happen at read not here (EISDIR)
        __when_exception e
      end

      ::Errno::ENOENT::FEENOFENT = :xx

      # -- support (re-used or likely to be )

      define_method :__when_exception, DEFINITION_FOR_THE_METHOD_CALLED_EXCEPTION_
    # -

    # ==

    # ==
    # ==
  end
end
# #born.
