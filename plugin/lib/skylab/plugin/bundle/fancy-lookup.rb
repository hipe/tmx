module Skylab::Plugin

  class Bundle::Fancy_lookup  # exegesis at [#024], which has..

    # incomplete pseudocde for a [#.A] general & [#.B] particular algorithm

    Attributes_actor_ = -> cls, * a do
      Home_.lib_.fields::Attributes::Actor.via cls, a
    end

    Attributes_actor_.call( self,
      entry_group_head_filter: nil,
    )

    def initialize
      @entry_group_head_filter = nil
    end

    def against sym, mod

      otr = dup
      otr.__init_first_frame sym.id2name, mod
      otr.__execute
    end

    def __init_first_frame s, mod

      _tokenizer = Tokenizer_via_full_string___[ s ]

      received_s_a = s.split UNDERSCORE_, -1

      _const_s_a = Const_string_array_via___[ received_s_a ]

      @__first_frame = BranchFrame__.new(
        _tokenizer, _const_s_a, received_s_a, mod, @entry_group_head_filter
      )
      NIL
    end

    Tokenizer_via_full_string___ = -> s do
      _s_a = s.downcase.split UNDERSCORE_, -1
      Parse_lib_[].input_stream.via_array _s_a
    end

    Const_string_array_via___ = -> s_a do

      d = 0  # (handle trailing underscores in an OCD way)
      if s_a.last.length.zero?
        s_a = s_a.dup
        begin
          s_a.pop
          d += 1
        end while s_a.last.length.zero?
      end

      const_s_a = s_a.map do |s|
        "#{ s[ 0 ].upcase }#{ s[ 1..-1 ] }"
      end

      d.times do
        const_s_a.push EMPTY_S_
      end

      const_s_a
    end

    def __execute

      frame = remove_instance_variable :@__first_frame

      begin

        if frame.has_the_answer_right_now
          x = frame.value_x
          break
        end

        frame = frame.next_frame

        if frame.is_the_answer
          x = frame.value_x
          break
        end
        redo
      end while above

      x
    end

    # ==

    class BranchFrame__

      def initialize st, s_a, s_a_, mod, rx
        @const_string_array = s_a
        @module = mod
        @received_string_array = s_a_
        @stem_name_filter_regexp = rx
        @stream = st
        @stream_offset = st.current_index
      end

      def has_the_answer_right_now

        const = @const_string_array[ @stream_offset .. -1 ].join( UNDERSCORE_ ).intern

        if @module.const_defined? const, false
          @_value_x = @module.const_get const, false
          ACHIEVED_
        else
          UNABLE_
        end
      end

      def value_x
        remove_instance_variable :@_value_x
      end

      def next_frame

        @file_tree = @module.entry_tree

        # advance scanner to boundary between one node and the next (money):

        __parse_to_init_state_machine

        at_the_end = @stream.no_unparsed_exists  # #note-05

        __init_const

        if @module.const_defined? @const, false

          if at_the_end
            self._VALUE_IS_RESULT
          else
            _mod = @module.const_get @const, false
            _build_frame_as_next_frame_for_this_module _mod
          end

        elsif at_the_end

          __frame_when_load_final_node
        else
          _next_frame = __frame_when_produce_nonfinal_node
          _next_frame  # #todo
        end
      end

      def __frame_when_load_final_node

        _load_path = _any_load_file_path
        ::Kernel.load _load_path

        x = @module.const_get @const, false

        if Autoloader_::Is_probably_module[ x ]

          _node_path = @state_machine.get_node_path

          Autoloader_[ x, _node_path, :autoloaderized_parent_module, @module ]
        end

        TheAnswer___.new x
      end

      def __frame_when_produce_nonfinal_node

        mod = ::Module.new

        @module.const_set @const, mod

        _node_path = @state_machine.get_node_path

        Autoloader_[ mod, _node_path, :autoloaderized_parent_module, @module ]

        __possibly_load_the_asset

        _build_frame_as_next_frame_for_this_module mod
      end

      def __possibly_load_the_asset

        load_path = _any_load_file_path

        if load_path
          ::Kernel.load load_path
        end
      end

      def _build_frame_as_next_frame_for_this_module mod

        _next_frame = BranchFrame__.new(
          @stream,
          @const_string_array,
          @received_string_array,
          mod,
          @stem_name_filter_regexp
        )

        _next_frame  # #todo
      end

      def _any_load_file_path

        eg = @state_machine.entry_group

        if eg.includes_what_is_probably_a_file
          @state_machine.get_filesystem_path
        else
          sm = @file_tree.corefile_state_machine
          if sm
            self._OK_probably_fine
            sm.get_filesystem_path
          end
        end
      end

      def __init_const

        current_index = @stream.current_index
        d = @stream_offset
        d_ = current_index - 1
        s_a = ::Array.new current_index - @stream_offset

        begin
          s = @received_string_array.fetch d
          s_a[ d - @stream_offset ] = "#{ s[ 0 ].upcase }#{ s[ 1 .. -1 ] }"
          d_ == d and break
          d += 1
          redo
        end while above

        @const = s_a.join( UNDERSCORE_ ).intern
        NIL
      end

      def __parse_to_init_state_machine

        _pf = Parse_function_via_file_tree[ @file_tree, @stem_name_filter_regexp ]

        _result = _pf.output_node_via_input_stream @stream

        @state_machine = _result.value_x
        NIL
      end

      def is_the_answer
        false
      end
    end

    # ==

    class TheAnswer___
      def initialize x
        @value_x = x
      end
      attr_reader(
        :value_x,
      )
      def is_the_answer
        true
      end
    end

    # ==

    Parse_function_via_file_tree = -> ft, rx do

      _on_error = -> *, & ev_p do
        raise ev_p[].to_exception
      end

      Parse_lib_[].function( :item_from_matrix ).new_with(

        :item_stream_proc, -> do

          st = ft.to_state_machine_stream

          Common_.stream do

            begin
              sm = st.gets
              sm || break
              rx =~ sm.entry_group_head ? redo : break
            end while above

            if sm
              Common_::Pair.via_value_and_name(
                sm,
                sm.entry_group_head.split( DASH_ ) )
            end
          end
        end,
        & _on_error
      )
    end

    # ==

    Parse_lib_ = Common_::Lazy.call do
      Home_.lib_.parse
    end

    # ==
  end
end
# #tombstone: introduced frames during autoloader rewrite
# :+#tombstone: was originally implemented in a functional style as an excercise
