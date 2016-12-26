module Skylab::CodeMetrics

  class Magnetics_::Node_for_Treemap_via_Recording < Common_::Actor::Dyadic

    # turn a flat list (stream) of events (modules, files, line numbers)
    # into a data tree suitable for a treemap visualiztion.

    # -
      def initialize rec, req, & li
        @_listener = li
        @head_const = req.head_const
        @recording = rec
        @request = req
      end

      def execute
        if __resolve_file_box_via_recording
          case 1 <=> @_file_box.length
          when 0
            __when_file_box_has_one_item
          when -1
            __when_file_box_has_multiple_items
          else
            __when_file_box_has_no_items
          end
        end
      end

      def __when_file_box_has_multiple_items
        bx = remove_instance_variable :@_file_box
        if @request.do_paginate
          bx.to_value_stream.map_by do |file|
            file.to_node_for_treemap
          end
        else
          _st = bx.to_value_stream.expand_by do |file|
            file.to_frame_stream
          end
          _ma = ModuleAnnotation_via_FrameStream__[ _st, @head_const ]
          _root_label = "(#{ bx.length } files)"
          NodeForTreemap_via_ModuleAnnotation__[ _ma, _root_label ]
        end
      end

      def __when_file_box_has_one_item
        bx = remove_instance_variable :@_file_box
        bx.fetch( bx.first_name ).to_node_for_treemap
      end

      def __resolve_file_box_via_recording
        _rec = remove_instance_variable :@recording
        _ = FileBox_via_Recording__[ _rec, @request ]
        _store :@_file_box, _
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -
    # ==

    class File___

      def initialize frz, path, hc
        @__frames = frz
        @head_const = hc
        @path = path
        freeze
      end

      def to_node_for_treemap
        _st = to_frame_stream
        _ma = ModuleAnnotation_via_FrameStream__[ _st, @head_const ]
        NodeForTreemap_via_ModuleAnnotation__[ _ma, @path ]
      end

      def to_frame_stream
        FrameStream_via_FramesOfFile___[ @__frames ]
      end
    end

    # ==

    NodeForTreemap_via_ModuleAnnotation__ = -> module_annotation, root_label do

      _Treemap = Home_.lib_.treemap  # 1x

      recurse = -> node, ma do

        # while not [#007.B] whitespace, we ignore line-age if the node
        # has children, i.e only terminal nodes will have a declared qty.

        # we tacitly assume that it has at one or both of lines, children.

        if ma.has_children
          ma.each_pair do |const, ma_|
            node.add_child_by do |no|
              no.label_string = const.id2name
              recurse[ no, ma_ ]
              NIL
            end
          end
        else
          _total_number_of_lines = ma.line_spans.reduce 0 do |d, r|
            d + r.size
          end
          node.main_quantity = _total_number_of_lines
        end
        NIL
      end

      _Treemap::Models::Node.define do |defn|

        defn.label_string = root_label

        recurse[ defn, module_annotation ]
      end
    end

    # ==

    const_tailer_via_head = Tailerer_via_separator_[ CONST_SEP_ ]

    ModuleAnnotation_via_FrameStream__ = -> frame_st, head_const do

      # for each module that is the module of interest or is taxonomically
      # a child of it, shorten its module name so it's only the any tail..

      # (see also the model)
      # (below is very similar to [ba]::Pathname::Localizer

      # -
        tailer = if head_const
          const_tailer_via_head[ head_const ]
        else
          -> const_s do
            const_s  # hi. if no head_const, all consts pass and be full.
          end
        end

        root = ModuleAnnotation__.new
        begin
          frame = frame_st.gets
          frame || break

          curr = root

          # ~
          _as_s = frame.qualified_const_symbol.id2name
          tail = tailer.call( _as_s ) { NOTHING_ }
          if tail
            scn = Home_::Models_::Const::ConstScanner.via_string tail
            begin
              _const = scn.gets_one.intern
              curr = curr.touch _const
            end until scn.no_unparsed_exists
          end
          # ~

          curr.add_line_span frame
          redo
        end while above

        root.finish
      # -
    end

    # ==

    class ModuleAnnotation__

      # the module annotation (tree) knows each of the zero or more line
      # spans under the module, and also each of its the child modules.

      # it's not quite simple enough to pass to the mondrian renderer.
      # it's almost complex enough that we could use it for [#007.F]
      # the hack we imagine for procs thru consts.

      def initialize
        @_receive_line_span = :__receive_initial_line_span
        @_touch = :__touch_first
        @line_spans = []
      end

      def touch const
        send @_touch, const
      end

      def __touch_first const
        @_a = [] ; @_h = {}
        @has_children = true
        @_touch = :__touch_normally
        send @_touch, const
      end

      def __touch_normally const
        @_h.fetch const do
          @_a.push const
          @_h[ const ] = self.class.new
        end
      end

      def add_line_span fr
        send @_receive_line_span, fr
      end

      def __receive_initial_line_span fr
        @has_lines = true
        @line_spans = []
        @_receive_line_span = :__receive_line_span_normally
        send @_receive_line_span, fr
      end

      def __receive_line_span_normally fr
        @line_spans.push(
          fr.beginning_line_number .. fr.ending_line_number )
        NIL
      end

      def finish
        remove_instance_variable :@_receive_line_span
        remove_instance_variable :@_touch
        if has_children
          @_a.freeze
          @_h.values.each( & :finish )
          @_h.freeze
        end
        if has_lines
          @line_spans.freeze
        end
        freeze
      end

      def each_pair
        @_a.each do |const|
          yield const, @_h.fetch( const )
        end
        NIL
      end

      attr_reader(
        :has_children,
        :has_lines,
        :line_spans,
      )
    end

    # ==

    FrameStream_via_FramesOfFile___ = -> frames_of_file do

      # (in the following paragraph we describe a means of filtering out
      # modules that are not within our "module of interest" - we discarded
      # this feature when we scaled up to supporting file globs because no
      # longer were we indicating a single "module of interest" but rather
      # a whole tree of files. and this feature was never really practical
      # anyway - by default the visualization expresses only leaf nodes so
      # the effect of extraneous-feeling "wrapper modules" (lexical branch
      # nodes) should be imperceptible anyway, maybe.) but we are leaving
      # the implementing code mostly intact because it is inert enough, the
      # comment is food for thought, and maybe we'll bring the feature back
      # one day. #tombstone-A)

      # a file can open and then close any arbitrary modules. and any
      # arbitrary module can be opened and then closed inside any other
      # module. we are only interested in modules that are under
      # (taxonomically not lexically) the module of interest so filter
      # out the others.

      # -

        pass = MONADIC_TRUTH_  # while this feature is furloughed. imagine:

        # rx = /\A#{ request.module_of_interest_name }(?=::|\z)/
        # pass = -> frame do
        #   rx =~ frame.qualified_const_symbol
        # end

        stream_via_frame = nil
        stream_via_frames = -> frames do
          Stream_[ frames ].expand_by do |fr|
            stream_via_frame[ fr ]
          end
        end

        stream_via_frame = -> frame do
          if pass[ frame ]
            if frame.has_children
              p = nil
              q = -> do
                p = stream_via_frames[ frame._children_ ]
                q = nil
              end
              p = -> do
                q[]
                frame
              end
              Common_.stream { p[] }
            else
              Common_::Stream.via_item frame
            end
          elsif frame.has_children
            stream_via_frames[ frame._children_ ]
          end
        end

        stream_via_frames[ frames_of_file ]
      # -
    end

    # ==

    class FileBox_via_Recording__ < Common_::Actor::Dyadic

      # the stream of tuples can jump around among files as one file loads
      # another file and so on. but towards our objective we see each file
      # as building its own tree - that's what we're after in the
      # visualiztion (A) and (B) we consider monkey-patching an abhorrent
      # practice.
      #
      # then within each file (path), manage a frame stack that pushes and
      # pops with each `class` and `end` event in that file. at the "end"
      # of each file (and we never know when we reach the end of a file,
      # because there is no such event for this, so at the end end) assert
      # that each stack for each file collapsed back down to its root.
      #
      # at the end with no errors we have one root frame per file..

      def initialize rec, req
        @__recording = rec
        @__request = req
      end

      def execute
        if __resolve_initial_box
          __finish
        end
      end

      def __finish
        ok = true
        bx = remove_instance_variable :@__initial_box
        bx.each_pair do |k, mf|
          ok = mf.finish
          ok || break
          bx.replace k, ok  # or just make a new box
        end
        ok && bx.freeze
      end

      def __resolve_initial_box
        ok = true
        box = Common_::Box.new
        st = remove_instance_variable( :@__recording ).to_event_tuple_stream
        begin
          tu = st.gets
          tu || break
          ok = box.touch tu.path do
            StackInProgress___.new tu.path, @__request
          end.push_or_pop tu
          ok || break
          redo
        end while above
        if ok
          @__initial_box = box
        end
        ok
      end
    end

    class StackInProgress___

      def initialize path, req
        @__do_debug = req.be_verbose
        @__debug_IO = req.debug_IO

        @_stack = []

        @head_const = req.head_const
        @path = path
      end

      def push_or_pop tu
        send ON_WHAT__.fetch( tu.event_symbol ), tu
      end

      ON_WHAT__ = {
        class: :__on_class,
        end: :__on_end,
      }

      def __on_class tu
        _trace { "#{ LNF__ % tu.lineno }: push atop #{ @_stack.length }" }
        fr = Frame__.new tu.qualified_const_symbol
        fr.change_state_to_open tu.lineno
        @_stack.push fr
        ACHIEVED_
      end

      def __on_end tu
        top = @_stack.fetch( -1 )
        exp_mod = top.qualified_const_symbol
        act_mod = tu.qualified_const_symbol
        if exp_mod == act_mod
          __do_pop tu
        else
          __when_bad_pop exp_mod, act_mod, tu
        end
      end

      def __when_bad_pop exp_mod, act_mod, tu
        self.__COVER_ME__code_sketch_of_corrupt_pop__
        _msg = "expected #{ exp_mod }, had #{ act_mod } #{
          }in #{ tu.path }#{ tu.lineno }"
        fail _msg
      end

      def __do_pop tu

        fr = @_stack.pop
        fr.change_state_to_closed tu.lineno
        if @_stack.length.zero?
          ( @_frames ||= [] ).push fr.finish
        else
          @_stack.last.add_child fr.finish
        end
        d = @_stack.length
        _trace { "#{ LNF__ % tu.lineno }: pop  now  #{ d }#{ '.' if d.zero? }" }
        ACHIEVED_
      end

      def _trace
        if @__do_debug
          @__debug_IO.puts yield
        end
        NIL
      end

      def finish
        if @_stack.length.zero?
          remove_instance_variable :@_stack
          @_frames.freeze
          File___.new remove_instance_variable( :@_frames ), @path, @head_const
        else
          self._COVER_ME__unexpected_end_of_input__
        end
      end

      LNF__ = '%4d'  # line number format
    end

    # ==

    class Frame__

      # for now, a structure (mutable at write time) for holding *one* line
      # span. originally was intended to hold multiple re-openings of the
      # same module, but now this merging happens later in this document
      # so that we attempt to do less work during record (fragile) time.
      # (was.)

      def initialize qcs
        @_receive_child = :__receive_first_child
        @_state = :beginning

        @qualified_const_symbol = qcs
      end

      def change_state_to_open d
        send STATES__.fetch( @_state ).fetch( :open ), d
        NIL
      end

      def change_state_to_closed d
        send STATES__.fetch( @_state ).fetch( :closed ), d
        NIL
      end

      STATES__ = {
        beginning: {
          open: :__note_opening_line_number,
        },
        open: {
          closed: :__note_closing_line_number,
        }
      }

      def __note_opening_line_number d
        @_state = :open
        @beginning_line_number = d ; nil
      end

      def __note_closing_line_number d
        @_state = :closed
        @ending_line_number = d ; nil
      end

      def add_child x
        send @_receive_child, x
      end

      def __receive_first_child x
        @has_children = true
        @_children_ = []
        send ( @_receive_child = :__receive_child_normally ), x
      end

      def __receive_child_normally x
        @_children_.push x ; nil
      end

      # --

      def finish
        remove_instance_variable :@_receive_child
        remove_instance_variable :@_state
        freeze
      end

      def _children_
        @_children_  # wz
      end

      attr_reader(
        :beginning_line_number,
        :ending_line_number,
        :has_children,
        :qualified_const_symbol,
      )
    end

    # ==

    # ==
  end
end
# #tombstone-A: no longer filter out modules based on module of interest
# #born for mondrian
