module Skylab::Basic

  class OrderedCollection  # :[#003]

    # three laws. abstracted from semi-working real use case

    class << self
      alias_method :begin_empty, :new
      undef_method :new
    end  # >>

    # -

      def initialize cls

        @comparable_class = cls

        @_head_link, @_tail_link = Link___.build_head_and_tail
      end

      def insert_or_retrieve k, * p_a, & p

        p and p_a.push p
        2 < p_a.length and raise ::ArgumentError
        new_item_by, receive_existing = p_a

        right = @_tail_link
        begin
          left = right.prev

          if left.is_head
            _insert_to_its_right left, k, new_item_by
            break
          end

          _d = left.comparable.compare_against_key k
          case _d

          when -1  # the current piece belongs to the left of the reference
            # piece so: we have found the "jump" piece.

            _insert_to_its_right left, k, new_item_by
            break

          when 0
            # found same key. call that one proc.
            receive_existing[ left.comparable.item ]
            break

          when 1  # the current piece belongs to the right of the reference
            # piece so: the new piece should to to the *left* of `left`.
            # so keep looking..

            right = left
            redo

          end
        end while above
        NIL
      end

      def _insert_to_its_right left, k, new_item_by

        _user_x = new_item_by[ k ]

        _cmp = @comparable_class.new k, _user_x

        new_tail_link = left._insert_to_the_right_ _cmp

        if new_tail_link
          self._WHY_REVIEW
          @_tail_link = new_tail_link
        end

        NIL
      end

      def remove_head_comparable
        if @_head_link.next.is_tail
          self._DESIGN_ME_slash_COVER_ME
        else
          @_head_link.__remove_to_the_right_
        end
      end

      def head_item
        @_head_link.next.comparable.item
      end

      def is_empty

        if @_tail_link.prev.is_head
          @_head_link.next.is_tail || self._SANITY
          true
        elsif @_head_link.next.is_tail
          self._SANITY
        end
      end

    # -

    # ==

    class Link___

      class << self

        def build_head_and_tail

          tail = This__.allocate.instance_exec do
            @is_head = false
            @is_tail = true
            self
          end

          head = This__.allocate.instance_exec do
            @is_head = true
            @is_tail = false
            @next = tail
            self
          end

          tail.instance_variable_set :@prev, head

          [ head, tail ]
        end

        alias_method :_new, :new
        undef_method :new
      end  # >>

      def initialize prev, cmp, nxt
        if prev
          if nxt
            if cmp
              @is_head = false
              @prev = prev
              _accept_comparable cmp
              @next = nxt
              @is_tail = false
            else
              fail  # must have cmp if have neighbor
            end
          elsif cmp
            @is_head = false
            @prev = prev
            _accept_comparable cmp
            @is_tail = true
          else
            fail  # same
          end
        elsif nxt  # no prev
          if cmp
            @is_head = true
            _accept_comparable cmp
            @next = nxt
            @is_tail = false
          else
            fail  # same
          end
        elsif cmp
          fail  # can't have cmp without neigbors
        else
          fail  # hi. can't build empty link (except #here3)
        end
      end

      def _accept_comparable x
        @comparable = x
        NIL
      end

      def _insert_to_the_right_ cmp  # results in new link IFF new link is new tail

        if @is_tail
          __untail cmp
        else
          __do_insert_to_the_right cmp
        end
      end

      def __untail cmp

        new_link = This__._new self, cmp, NOTHING_
        @next = new_link
        @is_tail = false
        new_link
      end

      def __do_insert_to_the_right cmp

        my_former_next_link = remove_instance_variable :@next

        @next = my_former_next_link._change_previous do |me|

          This__._new me, cmp, my_former_next_link
        end

        NOTHING_
      end

      def __remove_to_the_right_  # assume..

        # assume the going away piece is not the tail piece.

        # me [ga]    [me] going-away [far]    [ga] far

        going_away = remove_instance_variable :@next
        going_away.is_tail && fail

        me = going_away.remove_instance_variable :@prev
        far = going_away.remove_instance_variable :@next

        object_id == me.object_id || self._SANITY

        far._change_previous { me }

        @next = far

        # me [far]   [me] far

        going_away.comparable
      end

      def _change_previous
        _former_prev = remove_instance_variable :@prev
        new_prev = yield _former_prev
        new_prev || self._SANITY
        @prev = new_prev
        new_prev
      end

      protected :_change_previous

      def prev
        @prev
      end

      def comparable
        @comparable
      end

      def next
        @next
      end

      attr_reader(
        :is_head,
        :is_tail,
      )

      This__ = self
    end

    # ==
  end
end
# #born: early abstracted for multi-mode argument scanner
