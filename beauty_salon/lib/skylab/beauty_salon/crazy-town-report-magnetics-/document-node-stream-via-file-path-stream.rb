module Skylab::BeautySalon

  class CrazyTownReportMagnetics_::DocumentNodeStream_via_FilePathStream < Common_::SimpleModel

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

        lib = Home_::CrazyTownMagnetics_
        lc = lib::LineStream_via_DocumentNodeStream::StatefulLineCachingThing.new

        _dp = lib::DocumentProcessors_via_Definition.call_by do |o|
          yield lc.line_yielder, o
        end

        _etc_st = remove_instance_variable :@__potential_sexp_stream

        lib::LineStream_via_DocumentNodeStream.call_by do |o|
          o.document_processors = _dp
          o.per_file_line_cache = lc.line_cache
          o.potential_node_stream = _etc_st
        end
      end

      def __init_potential_sexp_stream

        proto = Potential_AST___.new self

        _file_path_st = remove_instance_variable :@file_path_upstream

        @__potential_sexp_stream = _file_path_st.map_by do |path|

          $stderr.puts "OHAI: #{ path }"  # #todo - leaving this in until maybe there is a verbose mode ..

          proto.dup.__init_new_instance_ path
        end

        NIL
      end
    # -  # (will re-open)

    # ==

    class Potential_AST___

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

      def file_lines_cache__ path

        ( @___file_lines_cache ||= FileLinesCacheCollection___.new( @filesystem ) ).__lines_via_path_ path
      end

      # -- interface with 'ruby_parser' (COMPREHENSIVE)

      def __init_ruby_parser
        @__ruby_parser = For_now_always_the_same_ruby_parser_with_certain_settings___[]
        NIL
      end
    # -

    # ==

    class FileLinesCacheCollection___

      def initialize fs
        @_cache = {}
        @filesystem = fs
      end

      def __lines_via_path_ path
        @_cache.fetch path do
          x = __work path
          @_cache[ path ] = x
          x
        end
      end

      def __work path
        @filesystem.open path do |io|
          a = [] ; line = nil
          a.push nil  # YIKES - so that we can use line numbers not offsets to reference lines
          begin
            line = io.gets
            line || break
            line.freeze
            a.push line
            redo
          end while above
          FileLinesCache___.new a.freeze
        end
      end
    end

    # ==

    class FileLinesCache___
      def initialize s_a
        @__lines = s_a
        freeze
      end
      def line_via_lineno__ d
        @__lines.fetch d
      end
    end

    # ==

    class WrappedDocumentAst___
      # (it's bad style to pass a tuple around as an array)

      def initialize ast, these, path
        @ast_ = ast
        @COMMENT_THINGS = these
        @path = path
        freeze
      end

      attr_reader(
        :ast_,  # the name is a reminder that its our name not theirs
        :path,
      )
    end

    # ==

    For_now_always_the_same_ruby_parser_with_certain_settings___ = Lazy_.call do  # #testpoint

      # require 'parser/current'  # we don't want the warning about etc
      require 'parser'

      parser = ::Parser
      parser::Builders::Default.modernize

      # doing the above is the same as doing
        # Default.emit_lambda = true
        # Default.emit_procarg0 = true
      # for which "all new code should set this attribute to true"

      require 'parser/ruby24'
      parser::Ruby24
    end

    # ==

    # ==
    # ==
  end
end
# #history-A.1: begin to bleed in 'parser' for 'ruby_parser'
# #born.
