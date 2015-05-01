module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Hack_guess_module_tree__  # :[#107].

        # the darkest of all hacks in this universe - we brought this file
        # back from four months in oblivion (where it belonged) and re-wrote
        # it completely: it tries to infer the "module tree" expressed by the
        # code in a file.

        # this is "useful" here because we want a user-defined file to
        # have any arbitary taxonomy of nested modules in it (that is, a
        # "module tree"), yet still we want to be able to find the one
        # function (stored in a const) we are looking for.

        # we jump through these nasty hoops because we don't want to
        # contribute to the equally nasty problem of polluting (or dictating
        # the use of) namespaces - let the user decide which namespaces to
        # use (if any), we just want the "leaf" we are loooking for, and
        # don't know where to look.

        # yes there are other ways to "solve" this "problem", but none of
        # them felt sufficiently isomorphic or sufficiently zero-config.

        # this, however, will certainly fail if the assumed conventions
        # aren't followed in the input file.

        class << self

          def new_via_arglist a, & oes_p
            if 1 == a.length
              a.unshift :path
            end
            new_via_iambic a, & oes_p
          end
        end

        Callback_::Actor.methodic self, :simple, :properties,

          :iambic_writer_method_to_be_provided, :property, :line_upstream,

          :iambic_writer_method_to_be_provided, :property, :path,

          :property, :on_event_selectively

        Callback_::Event.selective_builder_sender_receiver self

     private

        def initialize
          @resolve_line_upstream_method_name = :when_no_upstream
          @stack = [] ; @tops = []
          super
          @on_event_selectively ||= -> i, *, & ev_p do
            if :error == i
              raise ev_p[].to_exception
            end
          end
        end

        def line_upstream=
          x = iambic_property
          if x
            @line_upstream = x
            @resolve_line_upstream_method_name = :OK
          end
          KEEP_PARSING_
        end

        def path=
          x = iambic_property
          if x
            @path = x
            @resolve_line_upstream_method_name = :via_path_resolve_line_upstream
            nil
          end
          KEEP_PARSING_
        end

        public def execute
          normalize && work
        end

        # ~ normalize

        def normalize
          send @resolve_line_upstream_method_name
        end

        def when_no_upstream
          maybe_send_event :error, :no_upstream do
            build_not_OK_event_with :no_upstream
          end
        end

        def via_path_resolve_line_upstream
          @line_upstream = ::File.open @path, ::File::RDONLY
          @line_upstream ? ACHIEVED_ : UNABLE_
        end

        # ~ work

        def work
          @line = @line_upstream.gets
          if @line
            main_loop
          else
            when_empty_file
          end
        end

        def when_empty_file
          maybe_send_event :error do
            build_not_OK_event_with :file_was_empty, :path, @path
          end
          UNABLE_
        end

        def main_loop
          @ok = true
          begin

            @md = MODULE_LINE_RX_.match @line
            if @md
              _ = when_module
              _ ? redo : break
            end


            @md = END_LINE_RX_.match @line
            if @md
              _ = when_end_line
              _ ? redo : break
            end


            @md = CONST_ASSIGNMENT_LINE_RX__.match @line
            if @md
              _ = when_const_assignment
              _ ? redo : break
            end


            _ = advance_line
            _ ? redo : break

          end while nil

          @ok and finish
        end

        END_LINE_RX_ = /\A(?<space>[[:space:]]*)end\b/

        _ = '[A-Z][A-Za-z0-9_]*'

        _name = "#{ _ }(?:::#{ _ })*"

        MODULE_LINE_RX_ =
          %r(\A (?<space>[[:space:]]*) (?:module|class)[ ] (?<name>#{ _name }) \b)x

        CONST_ASSIGNMENT_LINE_RX__ =
          %r(\A  (?<space>[[:space:]]*) (?<name>#{ _name })[ ]=[ ] )x

        def when_const_assignment
          @stack.push Module_Item__.via_matchdata @md
          @top = @stack.last
          when_end_line_normal
        end

        def when_module
          @stack.push Module_Item__.via_matchdata @md
          advance_line
        end

        def when_end_line
          if @stack.length.zero?
            # no modules or classes found in file. not an error.
            nil
          else
            @top = @stack.last
            when_end_line_normal
          end
        end

        def when_end_line_normal
          case @top.space.length <=> @md[ :space ].length
          when -1 ; when_end_is_deeper
          when  0 ; when_end_is_same_level
          when  1 ; when_end_is_shallower
          end
        end

        def when_end_is_deeper
          advance_line
        end

        def when_end_is_same_level
          if @top.space == @md[ :space ]
            top = @top
            @stack.pop
            @top = @stack.last
            if @stack.length.zero?
              @tops.push top
            else
              @top.add_child top
            end
            advance_line
          else
            self._WHEN_whitespace_convention_change
          end
        end

        def advance_line
          @line = @line_upstream.gets
          @line and PROCEDE_
        end

        def finish
          if @stack.length.zero?
            if @tops.length.zero?
              when_no_tops
            else
              finish_normal
            end
          else
            self._WHEN_unclosed_modules
          end
        end

        def when_no_tops
          Immu_Node__.the_empty_tree
        end

        def finish_normal
          me = self ; tops = @tops
          Immu_Node__.new do
            cx_a = []
            me.build_each_immutable_child tops, self do |x|
              cx_a.push x
            end
            @child_count = cx_a.length
            @children = cx_a.freeze
          end
        end

        public def build_each_immutable_child item_a, parent
          me = self
          ( item_a.each do |item|
            _node = Immu_Node__.new do
              @parent = parent
              @value_x = item.name_i_a
              if item.has_children
                cx_a = []
                me.build_each_immutable_child item.children, self do |x|
                  cx_a.push x
                end
                @child_count = cx_a.length
                @children = cx_a.freeze
              else
                @child_count = 0
              end
            end
            yield _node
          end )
          nil
        end

        Immu_Node__ = Headless_.lib_.tree_lib.immutable_node

        def OK
          ACHIEVED_
        end

        class Module_Item__

          class << self
            alias_method :via_matchdata, :new
            private :new
          end

          def initialize md
            @space, name_s = md.captures
            @name_i_a = name_s.split( CONST_SEP_ ).map( & :intern ).freeze
            @cx_a = nil
          end

          attr_reader :name_i_a, :space

          def has_children
            ! @cx_a.nil?
          end

          def children
            @cx_a
          end

          def add_child x
            @cx_a ||= []
            @cx_a.push x ; nil
          end
        end
      end
    end
  end
end
