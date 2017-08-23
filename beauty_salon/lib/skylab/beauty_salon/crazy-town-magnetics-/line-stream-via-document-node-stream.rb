module Skylab::BeautySalon

  class CrazyTownMagnetics_::LineStream_via_DocumentNodeStream < Common_::MagneticBySimpleModel

    # at a macro level: for the typical report (a category that to date
    # encompasses every report we've conceived of), we hit a wall if we
    # don't and scale "infinitely" if we do implement ourselves as a stream
    # that *pulls* from an upstream list (a potentially "inifintely" long
    # list) of files, processing each one in turn "on demand" as our own
    # output stream is consumed.
    #
    # (even reports that aggregate some kind of totals or other statistics
    # can work under this paradigm at scale: the output for each file is
    # expressed as the file is traversed, while memoizing whatever pertinent
    # summary information from each file. once the last file has been
    # traversed, the aggregate summary ouput is assembled and flushed.)
    #
    # contrast this with an imaginary arrangement where we loop over every
    # of a huge list of files, needing to parse every one one and gather its
    # output data in memory before any output is expressed at all. yikes!
    #
    # however: at a micro level, each file needs to be parsed in-full all at
    # once (a requirement that is intrinsic to the grammar we are targeting).
    # as such, operations on the intra-file level don't happen using stream
    # mechanics but rather we use event-based triggers that write to some
    # kind of output context (for now always a plain old "line yielder"
    # (imagine STDOUT)).
    #
    # mainly, the subject bridges these two paradigms by caching lines from
    # the one and flushing them out to the other.

    # -

      attr_writer(
        :document_processors,
        :per_file_line_cache,
        :potential_node_stream,
      )

      def execute

        st = remove_instance_variable :@potential_node_stream

        dp = remove_instance_variable :@document_processors

        on_each_file_path = dp.receive_each_file_path__

        line_cache = remove_instance_variable :@per_file_line_cache

        main = nil ; p = nil

        line_st = nil

        descend_into_flush_lines_mode = -> use_this_proc_after do
          line_st = Stream_[ line_cache ]  # not threadsafe (duh)
          p = -> do
            line = line_st.gets
            if line
              line
            else
              p = use_this_proc_after ; p[]
            end
          end ; nil
        end

        close = -> do
          p = EMPTY_P_ ; NOTHING_
        end

        after_final_hook = -> do
          if line_cache.length.zero?
            close[]
          else
            descend_into_flush_lines_mode[ close ]
          end
        end

        main = -> do

          begin
            ps = st.gets

            line_cache.clear  # sometimes redundant

            if ! ps
              # (when you finished processing the last file, either stop now or etc..)
              pp = dp.proc_for_after_last_file__
              if pp
                # (this proc takes no arguments, but it might write to the line cache
                pp[]
                after_final_hook[]
                x = p[]
              else
                close[]
              end
              break
            end

            MaybeActivatePlan___.new ps, dp do |o|
              on_each_file_path[ ps.path, o ]
            end

            if line_cache.length.zero?
              # (if no lines were expressed for this file, simply
              # go on to the next file. we do no expression of this
              # fact here -- that is what the ps are for.)
              redo
            end

            # now you have nonzero lines. flush them and come back to here.

            descend_into_flush_lines_mode[ main ]
            x = line_st.gets
            break
          end while above
          x
        end

        p = main

        Common_.stream do
          p[]
        end
      end
    # -

    # ==

    class MaybeActivatePlan___

      # executed on every path in the big stream of paths, this exists
      # one-to-one with a DSL context that exists per one path

      def initialize ps, dp
        @__mutex_for_execute_document_processor = nil
        @__potential_node = ps
        @__document_processors = dp
        yield self
        send remove_instance_variable :@__execute
      end

      def execute_document_processor sym

        remove_instance_variable :@__mutex_for_execute_document_processor
        @__processor_symbol = sym
        @__execute = :__do_execute_document_processor ; nil
      end

      def __do_execute_document_processor

        _dp_sym = remove_instance_variable :@__processor_symbol
        _dp = @__document_processors.document_processors_hash.fetch _dp_sym
        _dp.process_document remove_instance_variable :@__potential_node
      end
    end
    # ==

    class StatefulLineCachingThing  # 1x

      # life is easier if ..

      def initialize
        a = []
        @line_yielder = ::Enumerator::Yielder.new do |line|
          a.push line
        end
        @line_cache = a
      end

      attr_reader(
        :line_cache,
        :line_yielder,
      )
    end

    # ==

    # ==
    # ==
  end
end
# #born.
