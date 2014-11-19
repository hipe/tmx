module Skylab::BeautySalon

  class Models_::Search_and_Replace

    class Actors_::Build_replace_function

      class Hack_guess_module_tree__

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

        # #todo - this unnecessarily makes three trees to make one - we
        # could just make the one from the start. setting out we thought
        # we should try to use [st] before writing it off. [ba]'s tree
        # is goofy and could stand for a rewrite.

        class << self
          def [] * a
            new( a ).execute
          end
        end

        BS_::Lib_::Event_lib[].sender self

        def initialize a
          @path, @on_event_selectively = a
          @stack = [] ; @tops = []
        end

        def execute
          @io = ::File.open @path, READ_MODE_
          @line = @io.gets
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

            _ = advance_line
            _ ? redo : break

          end while nil

          @ok and finish
        end

        END_LINE_RX_ = /\A(?<space>[[:space:]]*)end\b/

        _ = '[A-Z][A-Za-z0-9_]*'

        MODULE_LINE_RX_ = /\A(?<space>[[:space:]]*)(?:module|class)[ ](?<name>#{ _ }(?:::#{ _ })*)\b/

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

        class Module_Item__

          class << self

            def via_matchdata md
              new md
            end
          end

          def initialize md
            @space, name_s = md.captures
            @name_s_a = name_s.split CONST_SEP_
            @cx_a = nil
          end

          attr_reader :name_s_a, :space

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
          @line = @io.gets
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
          Node__.new( nil, nil )
        end

        def finish_normal
          @treelib  = BS_::Lib_::Tree_lib[]
          @from_tree = @treelib.new
          @to_node = @from_tree
          @from_children = @tops
          via_from_children
          @to_node = @from_children = @stack = @tops = nil
          via_from_tree
        end

        def via_from_children
          prev_to_node = @to_node
          @from_children.each do |child|
            child.name_s_a.each do |name_s|
              _cx = @to_node.fetch_or_create :path, [ name_s.intern ]
              @to_node = _cx
            end
            if child.has_children
              @from_children = child.children
              via_from_children
            end
            @to_node = prev_to_node
          end ; nil
        end

        def via_from_tree
          scn = @from_tree.get_traversal_scanner
          const_i_a = []
          final = Node__.new( nil, nil )
          parent_a = [ final ]
          scn.gets  # always discard the root
          while card = scn.gets
            idx = card.level - 1
            const_i_a[ idx ] = card.node.slug
            parent = parent_a.fetch idx
            box = Node__.new const_i_a[ 0, card.level ], parent
            parent.add box.name_i, box
            parent_a[ card.level ] = box
          end
          final
        end

        class Node__ < Callback_::Box

          def initialize const_i_a, parent
            super()
            const_i_a and @const_i_a = const_i_a
            if parent
              @has_parent = true
              @parent = parent
            end
          end

          attr_reader :const_i_a, :has_parent, :parent

          attr_accessor :value

          def name_i
            @const_i_a.last
          end

          def traverse & p
            if @a.length.nonzero?
              @h.values.each do |x|
                p[ x ]
                x.traverse( & p )
              end
            end
            nil
          end
        end
      end
    end
  end
end
