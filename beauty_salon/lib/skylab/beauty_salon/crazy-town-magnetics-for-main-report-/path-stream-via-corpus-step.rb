module Skylab::BeautySalon

  class CrazyTownMagneticsForMainReport_::PathStream_via_CorpusStep < Common_::MagneticBySimpleModel

    # this is a scratch-an-itch self-contained pet project ..
    #
    # the effect here is similar to test suite runners that note which
    # test was the last failing test and allow you to pick up the subsequent
    # test run from there. see [#042.B] for complete origin story and usage.

    # -

      attr_writer(
        :filesystem,
        :listener,
      )

      def initialize
        super
        @corpus_directory = '_CORPUS_'
        @corpus_order_file = '_CORPUS_ORDER_'
        @the_file = '.corpus-step.json'
      end

      def execute

        __init_state_file_contents
        __init_big_stepper

        if __maybe_advance
          __flush
        end
      end

      def __flush

        _st = __flush_stream

        o = Result___.new
          o.path_stream = _st
          o.save_corpus_step = method :__SAVE
        o.freeze
      end

      Result___ = ::Struct.new(
        :path_stream,
        :save_corpus_step,
      )

      def __flush_stream
        # hand-written map-expand
        p = nil
        lo_mode_read = nil
        hi_mode_read = -> do
          if @_big_stepper.step
            _reinit_small_stepper
            p = lo_mode_read
            p[]
          else
            $stderr.puts "(reached the end - maybe close that one file)"
            NOTHING_
          end
        end
        lo_mode_read = -> do
          if @_small_stepper.step
            @_small_stepper.line_item
          else
            p = hi_mode_read
            p[]
          end
        end
        p = -> do
          p = lo_mode_read
          @_small_stepper.line_item
        end
        Common_.stream() { p[] }
      end

      # --

      def __maybe_advance
        if @sidesystem_last_offset
          __advance
        else
          begin
            yes = @_big_stepper.step
            yes || break
            _reinit_small_stepper
            yes = @_small_stepper.step
          end until yes
          yes || self._COVER_ME__everything_is_empty__
        end
      end

      def __advance

        if _advance :big, :sidesystem, ::File.method( :basename )
          _reinit_small_stepper
          _advance :small, :file
        end
      end

      def _advance big_or_small, ss_or_file, cmp_p=IDENTITY_

        stepper = instance_variable_get :"@_#{ big_or_small }_stepper"  # @_big_stepper @_small_stepper

        expected_offset = instance_variable_get :"@#{ ss_or_file }_last_offset"  # @sidesystem_last_offset @file_last_offset

        target_s = instance_variable_get :"@#{ ss_or_file }_last_name"  # @sidesystem_last_name @file_last_name

        corrupt_m = :"__corrupt_#{ big_or_small }"  # __corrupt_big __corrupt_small
        not_found_m = :"__not_found_#{ big_or_small }"  # __not_found_big __not_found_small

        # --

        did_find = false
        begin
          _stay = stepper.step
          _stay || break

          if target_s == cmp_p[ stepper.line_item ]
            did_find = true
            break
          end
          redo
        end while above

        if did_find
          if expected_offset == stepper.offset
            ACHIEVED_
          else
            send corrupt_m, stepper.offset
          end
        else
          send not_found_m, stepper.number_of_items
        end
      end

      def __not_found_small d
        s = @file_last_name
        _corrupt :not_found do |y|
          y << "not found in #{ d } files: \"#{ s }\""
        end
      end

      def __not_found_big d
        s = @sidesystem_last_name
        _corrupt :not_found do |y|
          y << "not found in #{ d } sidesystems: \"#{ s }\""
        end
      end

      def __corrupt_small d
        dd = @file_last_offset
        s = @file_last_name
        _corrupt :corrupt do |y|
          y << "expected '#{ s }' at offset #{ dd }, but found it at offset #{ d }"
        end
      end

      def __corrupt_big d
        dd = @sidesystem_last_offset
        s = @sidesystem_last_name
        _corrupt :corrupt do |y|
          y << "expected '#{ s }' at offset #{ dd }, but found it at offset #{ d }"
        end
      end

      def _corrupt * sym_a, & p
        file = @the_file
        _express_error( * sym_a ) do |y|
          calculate y, & p
          y << "maybe remove this file to start from the beginning: #{ file }"
        end
      end

      # --

      def _reinit_small_stepper

        _path = ::File.join @corpus_directory, @_big_stepper.line_item

        @_small_stepper = LineStepper__.new @filesystem.open _path

        NIL
      end

      def __init_big_stepper
        @_big_stepper = LineStepper__.new @filesystem.open @corpus_order_file
        NIL
      end

      # --

      # --

      def __init_state_file_contents

        io = __some_writable_IO
        _json = io.read
        io.rewind
        @_writable_IO = io
        require 'json'

        @_hash = ::JSON.parse _json, symbolize_names: true
        ok = _integer :sidesystem_last_offset
        ok &&= _string :sidesystem_last_name
        ok &&= _integer :file_last_offset
        ok &&= _string :file_last_name
        @_hash.length.zero? || fail
        remove_instance_variable :@_hash
        ACHIEVED_
      end

      def _integer sym
        _type ::Integer, sym
      end

      def _string sym
        _type ::String, sym
      end

      def _type cls, sym
        x = __read sym
        if x.nil? || cls === x
          instance_variable_set "@#{ sym }", x
          ACHIEVED_
        else
          _express_error { "for '#{ sym }', needed #{ cls.name.downcase }: #{ x.inspect }" }
        end
      end

      def __read sym
        x = @_hash.fetch sym
        @_hash.delete sym
        x
      end

      def __some_writable_IO
        begin
          @filesystem.open @the_file, ::File::RDWR
        rescue ::Errno::ENOENT
          __write_file
        end
      end

      def __SAVE

        d = @_big_stepper.offset
        dd = @_small_stepper.offset

        o = {}
        o[ :sidesystem_last_name ] = @_big_stepper.line_item
        o[ :sidesystem_last_offset ] = d
        o[ :file_last_name ] = @_small_stepper.line_item
        o[ :file_last_offset ] = dd
        _json = ::JSON.pretty_generate o ; o = nil

        io = remove_instance_variable :@_writable_IO
        io.rewind
        io.truncate 0
        io.puts _json
        io.close
        @listener.call( :info, :expression ) { |y| y << "(wrote step offsets #{ d }:#{ dd } to #{ io.path })" }

        remove_instance_variable( :@_big_stepper ).close_early
        remove_instance_variable( :@_small_stepper ).close_early
        NIL
      end

      def __write_file
        the_file = @the_file
        @listener.call( :info, :expression ) { |y| y << "(creating file: #{ the_file })" }
        io = @filesystem.open @the_file, ::File::RDWR | ::File::CREAT
        io.write <<-HERE.gsub( %r(^ {10}), EMPTY_S_ )
          {
            "sidesystem_last_name": null,
            "sidesystem_last_offset": null,
            "file_last_name": null,
            "file_last_offset": null
          }
        HERE
        io.rewind
        io
      end

      # --

      def _express_error * chan_sym, & p
        if p.arity.zero?
          msg_proc = p
          p = -> y do
            y << calculate( & msg_proc )
          end
        end
        @listener.call :error, :expression, * chan_sym, & p
        UNABLE_
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

    # -

    # ==

    class LineStepper__

      def initialize io
        @step = :__step_initially
        @IO = io
      end

      def step
        send @step
      end

      def __step_initially
        line = @IO.gets
        if line
          @line_item = :__line_item
          @offset = :__offset
          @_line = line
          @_offset = -1
          @step = :__step_normally
          _finish_step
        else
          _receive_number_of_items 0
          _finish_close
        end
      end

      def __step_normally
        @_line = @IO.gets
        if @_line
          _finish_step
        else
          _receive_number_of_items @_offset + 1
          close_early
        end
      end

      def _finish_step
        @_line.chomp!
        @_offset += 1 ; true
      end

      def _receive_number_of_items d
        @_number_of_items = d
        @number_of_items = :__number_of_items ; nil
      end

      def close_early
        remove_instance_variable :@line_item
        remove_instance_variable :@offset
        remove_instance_variable :@_line
        remove_instance_variable :@_offset
        _finish_close
      end

      def _finish_close
        remove_instance_variable( :@IO ).close
        remove_instance_variable :@step
        freeze ; nil
      end

      def number_of_items
        send @number_of_items
      end

      def __number_of_items
        @_number_of_items
      end

      def line_item
        send @line_item
      end

      def offset
        send @offset
      end

      def __line_item
        @_line
      end

      def __offset
        @_offset
      end
    end

    # ==
    # ==
  end
end
# #born
