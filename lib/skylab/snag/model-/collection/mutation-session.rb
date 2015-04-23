module Skylab::Snag

  module Model_::Collection

    class Mutation_Session

      # an attempt to generalize prepends, appends, and removes
      # for all collections of associated entites of all entities

      class << self

        def call x_a, coll, & x_p

          if x_a.length.zero?

            if x_p  # no iambic and some block

              self._DESIGN_ME
            else  # no iambic and no block

              self._DESIGN_ME
            end
          else  # some iambic

            ok = false
            o = new coll do
              @on_event_selectively = x_p  # nil ok
              ok = process_arglist_fully x_a
            end
            ok && o.execute
          end
        end

        private :new
      end  # >>

      def initialize coll, & edit_p

        @_collection = coll
        @_do_check_for_redundancy = false
        instance_exec( & edit_p )
      end

    private

      def process_arglist_fully x_a

        rst = Snag_.lib_.basic::List.line_stream x_a

        @_x = rst.rgets

        sym = rst.gets
        sym and @_verb_symbol = sym

        sym = rst.gets
        sym and @_assocation_symbol = sym

        @_shape_symbol = rst.rgets  # nil OK

        if rst.eos?
          ok = true
        else
          @__methodic_actor_iambic_stream__ = rst  # lies
          begin
            sym = rst.gets
            sym or break
            ok = send :"#{ sym }="
            ok or break
            redo
          end while nil
          remove_instance_variable :@__methodic_actor_iambic_stream__

          if ok
            rst.eos? or raise ::ArgumentError  # sanity
          end
        end
        ok
      end

      def check_for_redundancy=
        @_do_check_for_redundancy = true
        KEEP_PARSING_
      end

      def do_prepend=
        x = iambic_property
        if x
          @_verb_symbol = :prepend
        end
        KEEP_PARSING_
      end

      def iambic_property
        @__methodic_actor_iambic_stream__.gets  # ish
      end

      public def execute

        @_collection.collection_was_changed_by_mutation_session_ = false
        ok = __resolve_entity
        ok &&= __maybe_check_for_redundancy
        ok &&= __resolve_mutable_body
        ok && __via_all
      end

      def __resolve_entity

        cls = @_collection.send(
          :"__#{ @_assocation_symbol }__class_for_mutation_session_" )

        sym = @_shape_symbol

        ent = if sym

          cls.send :"new_via__#{ sym }__", @_x, & @on_event_selectively
        else
          cls.new @_x
        end

        ent and begin
          @_entity = ent
          ACHIEVED_
        end
      end

      def __maybe_check_for_redundancy

        if @_do_check_for_redundancy

          _yes = @_collection.send(
            :"has_equivalent__#{ @_assocation_symbol }__object_",
            @_entity )

          if _yes
            __when_redundant
          else
            ACHIEVED_
          end
        else
          ACHIEVED_
        end
      end

      def __when_redundant

        @on_event_selectively.call :error, :entity_already_added do

          _event_class( :entity_already_added ).new_with(
            :entity, @_entity,
            :entity_collection, @_collection )
        end
        UNABLE_
      end

      def __resolve_mutable_body

        body = @_collection.mutable_body_for_mutation_session_
        body and begin
          @_body = body
          ACHIEVED_
        end
      end

      def __via_all

        ok = @_body.send(
          :"__#{ @_verb_symbol }__object_",
          @_entity,
          & @on_event_selectively )

        if ok
          @_collection.collection_was_changed_by_mutation_session_ = true

          if :remove == @_verb_symbol
            __maybe_emit_removed_entity_event ok
          end

        elsif :remove == @_verb_symbol
          ok = __when_not_found
        end
        ok
      end

      def __maybe_emit_removed_entity_event ent

        @on_event_selectively.call :info, :entity_removed do

          _event_class( :entity_removed ).new_with(
            :entity, ent,
            :entity_collection, @_collection )
        end
        NIL_
      end

      def __when_not_found

        @on_event_selectively.call :error, :entity_not_found do

          _event_class( :entity_not_found ).new_with(
            :entity, @_entity,
            :entity_collection, @_collection )
        end
        UNABLE_
      end

      def _event_class sym  # (placeholder)

        _ = Callback_::Name.via_variegated_symbol( sym ).as_const
        Model_::Collection::Event_Factory.const_get _
      end
    end
  end
end
