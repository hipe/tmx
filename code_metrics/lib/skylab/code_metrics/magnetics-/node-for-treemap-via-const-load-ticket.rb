module Skylab::CodeMetrics

  class Magnetics_::Node_for_Treemap_via_ConstLoadTicket < Common_::Actor::Monadic

    # the least hacky way we can accomplish what we're after (as far as
    # we've found) is to use `TracePoint` which can notify us when certain
    # events of interest occur like a module (e.g class) being opened, or
    # such a module's scope again closing.

    # pleasingly this gives us line numbers (otherwise we'd have to go much
    # darker); however we can't get notified of the blocks used to define
    # procs yet. we might hack something awful for that.

    # -

      def initialize const_load_ticket, & p

        @const_load_ticket = const_load_ticket
        @_listener = p
      end

      def execute

        __maybe_require_something

        __advance_to_the_last_element_in_the_const_path

        tr = TraceRecording_via_Const_and_Module___.call(
          remove_instance_variable( :@__const_to_load ),
          remove_instance_variable( :@__parent_module ),
        )

        _st = MatchingFrameStream_via_TraceRecording___[ tr ]

        _ma = ModuleAnnotation_via_MatchingFrameStream___[ _st, tr ]

        NodeForTreemap_via_ModuleAnnotation___[ _ma, tr ]
      end

      def __advance_to_the_last_element_in_the_const_path

        current_parent_module = ::Object
        _lt = remove_instance_variable :@const_load_ticket
        scn = _lt.const_scanner

        until scn.is_last
          const = scn.current_token
          next_value = current_parent_module.const_get const, false
          scn.advance_one
          current_parent_module = next_value
        end

        @__parent_module = current_parent_module
        @__const_to_load = scn.gets_one
        NIL
      end

      def __maybe_require_something
        rp = @const_load_ticket.require_path
        if rp
          self._EASY__but_cover_it__
        end
      end
    # -
    # ==

    NodeForTreemap_via_ModuleAnnotation___ = -> module_annotation, tr do

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

        defn.label_string = tr.module_of_interest_name

        recurse[ defn, module_annotation ]
      end
    end

    # ==

    ModuleAnnotation_via_MatchingFrameStream___ = -> frame_st, tr do

      # for each module that is the module of interest or is taxonomically
      # a child of it, shorten its module name so it's only the any tail..

      # (see also the model)

      # -

        head = tr.module_of_interest_name
        len = head.length
        head_r = 0 ... len
        tail_r = len + 2 .. -1
        tailer = -> mod_name do
          head == mod_name[ head_r ] || self._SANITY
          mod_name[ tail_r ]
        end

        root = ModuleAnnotation__.new
        begin
          frame = frame_st.gets
          frame || break

          curr = root

          mod_name = frame.module_name

          if head != mod_name

            _tail = tailer[ mod_name ]

            scn = Home_::Models_::Const::Scanner.via_string _tail

            begin

              curr = curr.touch scn.gets_one.intern

            end until scn.no_unparsed_exists
          end

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
      # it's almost complex enough that we could use it for [#007.F].

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

    MatchingFrameStream_via_TraceRecording___ = -> trace_recording do

      # a file can open and then close any arbitrary modules. and any
      # arbitrary module can be opened and then closed inside any other
      # module. we are only interested in modules that are under
      # (taxonomically not lexically) the module of interset so filter
      # out the others.

      # -
        rx = /\A#{ trace_recording.module_of_interest_name }(?=::|\z)/

        stream_via_frame = nil
        stream_via_frames = -> frames do
          Stream_[ frames ].expand_by do |fr|
            stream_via_frame[ fr ]
          end
        end

        stream_via_frame = -> frame do
          if rx =~ frame.module_name
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

        stream_via_frames[ trace_recording.frames ]
      # -
    end

    # ==

    class TraceRecording_via_Const_and_Module___ < Common_::Actor::Dyadic

      # the most fragile part. pain when an error occurs during recording,
      # it often makes the recording twist around on itself.

      def initialize ctl, pm
        @_DO_TRACE = false
        @const_to_load = ctl
        @parent_module = pm
      end

      def execute
        trace = TracePoint.new :class, :end do
          @_path = @_tracepoint.path
          case @_tracepoint.event
          when :class
            send @_on_class
          when :end
            send @_on_end
          else never
          end
        end
        @_on_class = :__on_class_initially
        @_on_end = :__on_end_initially
        @_tracepoint = trace
        trace.enable
        x = @parent_module.const_get @const_to_load, false
        trace.disable
        _ = remove_instance_variable :@_recorded_frames  # ..
        TraceRecording___.new x.name.freeze, _
      end

      TraceRecording___ = ::Struct.new :module_of_interest_name, :frames

      def __on_class_initially

        # when the file of interest is loaded, it can load arbitrary other
        # files that define arbitrary other modules. a naive approach here
        # to push and pop elements to stack would at best waste a lot of r.
        #
        # since we cannot know the path of interest until the const value
        # of interest is loaded, the only way to know the path of interest:

        if @parent_module.const_defined? @const_to_load, false
          __begin_recording
        end
      end

      def __on_end_initially
        _some_stderr.puts "#{ _lineno }: why is this end initially happening"
        _panic
      end

      def __begin_recording

        # KISS: once we know the path of interest, we use it (and the
        # stack size) to be the sole determiner of if we mutate the stack

        @_stack = []
        _on_push_normally
        @_path_of_interest = @_path
        @_on_class = :__on_class_normally
        @_on_end = :__on_end_normally
        @_on_push = :_on_push_normally
        @_on_pop = :_on_pop_normally
      end

      def __on_class_normally
        if @_path == @_path_of_interest
          send @_on_push
        else
          # _some_stderr.puts "(doing nothing on `class` open for strange path - #{ @_path }"
          self._COVER_ME__but_probably_fine__on_class_in_strange_path__
        end
      end

      def __on_end_normally
        if @_path == @_path_of_interest
          send @_on_pop
        else
          _trace { "(doing nothing on `end` for strange path - #{ @_path }" }
          # self._COVER_ME__but_probably_fine__on_end_in_strange_path__
        end
      end

      def __on_push_when_reopening
        _trace { "#{ _lineno }: push atop #{ @_stack.length }." }
        _do_push
        @_on_push = :_on_push_normally
        @_on_pop = :_on_pop_normally
      end

      def __on_pop_when_ignored
        _trace { "#{ _lineno }: IGNORING A POP" }
      end

      def _on_push_normally
        _trace { "#{ _lineno }: push atop #{ @_stack.length }" }
        _do_push
      end

      def _do_push
        rf = RecordingFrame__.new @_tracepoint.binding.receiver
        rf.change_state_to_open @_tracepoint.lineno
        @_stack.push rf
      end

      def _on_pop_normally
        top = @_stack.fetch( -1 )
        exp_mod = top.module
        act_mod = @_tracepoint.binding.receiver
        if exp_mod == act_mod
          _do_pop
          d = @_stack.length
          _trace do
            "#{ _lineno }: pop  now  #{ d }#{ '.' if d.zero? }"
          end
          if d.zero?
            @_on_push = :__on_push_when_reopening
            @_on_pop = :__on_pop_when_ignored
          end
        else
          io = _some_stderr
          io << "#{ _lineno }: RECORDING HACK FAILED on pop)"
          _panic
          # io << "(expected #{ exp_mod }, had #{ act_mod })"
          # _panic_and_exit
        end
      end

      def _do_pop
        rf = @_stack.pop
        rf.change_state_to_closed @_tracepoint.lineno
        if @_stack.length.zero?
          ( @_recorded_frames ||= [] ).push rf.finish
        else
          @_stack.last.add_child rf.finish
        end
      end

      def _panic_and_exit
        _some_stderr.puts "EXITING BECAUSE PANIC from [cm]"
        _panic ; exit 0
      end

      def _panic
        @_tracepoint.disable
      end

      def _lineno
        '%3d' % @_tracepoint.lineno
      end

      def _trace
        if @_DO_TRACE
          _some_stderr.puts yield
        end
      end

      def _trace_by
        if @_DO_TRACE
          yield _some_stderr
        end
      end

      def _some_stderr
        $stderr
      end
    end

    # ==

    class RecordingFrame__

      def initialize mod
        @_receive_child = :__receive_first_child
        @module = mod
        @_state = :beginning
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
        @module_name = @module.name
        freeze
      end

      def _children_
        @_children_  # wz
      end

      attr_reader(
        :beginning_line_number,
        :ending_line_number,
        :has_children,
        :module,
        :module_name,
      )
    end

    # ==
  end
end
# #born for mondrian
