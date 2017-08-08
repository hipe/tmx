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
        # (at #history-A.1, we got rid of meh and meh)

        _two = @__ruby_parser.parse_file_with_comments path
        WrappedDocumentAst___.new( * _two, path )
      end

      # -- interface with 'ruby_parser' (COMPREHENSIVE)

      def __init_ruby_parser
        Load_ruby_parser_with_specific_settings___[]

        @__ruby_parser = ::Parser::CurrentRuby  # ..

        # (:#spot1.1 used to be here, but it is DISASSOCIATED)
        NIL
      end
    # -

    # ==

    class WrappedDocumentAst___
      # (it's bad style to pass a tuple around as an array)
      def initialize ast, these, path
        @ast_ = ast
        @COMMENT_THINGS = these
        @PATH = path
      end
      attr_reader(
        :ast_,  # the name is a reminder that its our name not theirs
      )
    end

    # ==

    Load_ruby_parser_with_specific_settings___ = Lazy_.call do
      require 'parser/current'
      # opt-in to most recent AST format:
      ::Parser::Builders::Default.emit_lambda = true
      ::Parser::Builders::Default.emit_procarg0 = true
    end

    # ==



    # ==
    # ==
  end
end
# #history-A.1: begin to bleed in 'parser' for 'ruby_parser'
# #born.
