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

        @_args = nil

        st = Callback_::Polymorphic_Stream.new 0, x_a
        @_verb_symbol = st.gets_one
        @_association_symbol = st.gets_one
        @_x = st.gets_one
        @_shape_symbol = nil

        if st.no_unparsed_exists
          ok = true
        else

          @__methodic_actor_iambic_stream__ = st

          begin
            ok = send :"#{ st.gets_one }="
            ok or break
            if st.unparsed_exists
              redo
            end
            break
          end while nil

          remove_instance_variable :@__methodic_actor_iambic_stream__
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

      def modifiers=
        ( @_args ||= [] ).push iambic_property
        KEEP_PARSING_
      end

      def which_is=
        @_shape_symbol = iambic_property
        KEEP_PARSING_
      end


      def iambic_property
        @__methodic_actor_iambic_stream__.gets_one
      end

      public def execute

        ok = __resolve_entity
        ok &&= __maybe_check_for_redundancy
        ok &&= __resolve_mutable_body
        ok && __via_all
      end

      def __resolve_entity

        cls = @_collection.send(
          :"__#{ @_association_symbol }__class_for_mutation_session" )

        _m = :"new_via__#{ @_shape_symbol || :mixed }__"

        ent = cls.send _m, @_x, & @on_event_selectively

        ent and begin
          @_entity = ent
          ACHIEVED_
        end
      end

      def __maybe_check_for_redundancy

        if @_do_check_for_redundancy

          _yes = @_collection.send(
            :"has_equivalent__#{ @_association_symbol }__object_",
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

        body = @_collection.mutable_body_for_mutation_session_by @_verb_symbol
        if body
          @_body = body
          ACHIEVED_
        else
          self._SANITY
        end
      end

      def __via_all

        _m = if :receive == @_verb_symbol
          :"receive__#{ @_association_symbol }__for_mutation_session"
        else
          :"__#{ @_verb_symbol }__object_for_mutation_session"
        end

        ok_x = @_body.send _m, * @_args, @_entity, & @on_event_selectively

        if ok_x

          __result_for_mutation ok_x

        elsif :remove == @_verb_symbol

          __when_not_found
        else
          ok_x
        end
      end

      def __result_for_mutation ok_x

        ok = @_collection.receive_notification_of_change_during_mutation_session
        if ok
          if :remove == @_verb_symbol

            __result_for_removed_entity ok_x
          else
            ok_x
          end
        else
          ok
        end
      end

      def __result_for_removed_entity ent

        @on_event_selectively.call :info, :entity_removed do

          _event_class( :entity_removed ).new_with(
            :entity, ent,
            :entity_collection, @_collection )
        end

        ent
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
