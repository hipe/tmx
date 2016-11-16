module Skylab::Basic::TestSupport

  module Ordered_Collection

    def self.[] tcc
      tcc.include self
    end

    # -
      # --

      def expect_retrieve_ k, v
        _inst = subject_instance_
        x = nil
        res = _inst.insert_or_retrieve k, nil do |x_|
          x = x_
        end
        res.nil? || fail
        x == v || fail
      end

      # -- deep audit 2

      def array_via_deep_audit_

        a = []
        _o = subject_instance_
        left = _o.instance_variable_get :@_head_link

        left.instance_variable_defined? :@_prev_known and false
        left.is_head || fail

        begin
          # assume always there is a next (although the next might be tail)

          left.instance_variable_defined? :@_next_known or fail
          right = left.next

          right.prev.object_id == left.object_id || fail

          if right.is_tail
            right.instance_variable_defined? :@_next_known and fail
            break
          end

          a.push right.comparable.item
          left = right
          redo
        end while above
        a
      end

      # -- deep audit 1

      def expect_prev_and_next_ exp_prev, link, exp_next

        _expect_one_side link, :is_head, :@_prev_known, exp_prev, :prev
        _expect_one_side link, :is_tail, :@_next_known, exp_next, :next
        NIL
      end

      def _expect_one_side link, is_head_or_tail_m, ivar, exp_sym, prev_or_next_m

        if link.send is_head_or_tail_m
          link.instance_variable_defined?( ivar ) and fail
          exp_sym && fail  # ..
        else
          _prev_or_next_link = link.send prev_or_next_m
          act_sym = @symbol_via_object_id.fetch _prev_or_next_link.object_id
          if exp_sym
            act_sym == exp_sym || fail  # ..
          else
            fail  # ..
          end
        end
      end

      def name_these_ * x_a
        len = x_a.length
        d = 0
        h = {}
        until d == len
          h[ x_a.fetch( d ).object_id ] = x_a.fetch( d += 1 )
          d += 1
        end
        @symbol_via_object_id = h ; nil
      end

      # --

      def build_empty_subject_instance_
        subject_module_.begin_empty TS_::Ordered_Collection::CollectionClass
      end

      # --

      def subject_module_
        Home_::OrderedCollection
      end
    # -

    # ==

    class CollectionClass

      def initialize k, x
        @item = x
        @symbol___ = k
      end

      def compare_against_key k
        ORDER__.fetch( @symbol___ ) <=> ORDER__.fetch( k )
      end

      attr_reader(
        :item,
        :symbol___,  # testing only - not because of any API
      )

      self
    end

    ORDER__ = {
      key_1: 0,
      key_2: 1,
      key_3: 2,
    }

    # ==

  end
end
