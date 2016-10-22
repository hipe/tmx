module Skylab::TMX

  class Magnetics_::MappedStream_via_Derivations_and_MappedStream < Common_::Actor::Dyadic

    # public API methods effected:
    #   - `begin_deriver`
    #     - `see_and_or_mutate_for_derivation`
    #     - `apply_derivations`

    def initialize x, xx
      @modifiers = x
      @parsed_node_stream = xx
    end

    def execute
      __index_some_things
      __decide_some_things
      __flush_some_things
    end

    def __flush_some_things

      see_all = remove_instance_variable :@__all_nodes
      see_each = remove_instance_variable :@__each_node

      st = remove_instance_variable :@parsed_node_stream
      if see_each
        node_a = []
        begin
          node = st.gets
          node || break
          see_each[ node ]
          node_a.push node
          redo
        end while above
      else
        node_a = st.to_a
      end

      node_a.freeze
      if see_all
        see_all[ node_a ]
      end

      Stream_[ node_a ]
    end

    def __decide_some_things

      a = remove_instance_variable :@__eachers
      if a

        case 1 <=> a.length  # avoid looping in a loop if we can
        when 0  # when one
          each_node = Seer_via_deriver__[ * a.fetch(0) ]

        when -1  # when more than one
          see_a = a.map( & Seer_via_deriver__ )
          len = a.length
          each_node = -> node do
            d = len
            begin
              d -= 1
              see_a.fetch( d )[ 0 ]
            end until d.zero?
          end
        end
      end

      a = remove_instance_variable :@__allers
      if a
        all_nodes = -> do
          deri_a = a
          -> node_a do
            deri_a.each do |deri|
              deri.apply_derivations node_a
            end
            NIL
          end
        end.call
      end

      @__all_nodes = all_nodes
      @__each_node = each_node
      NIL
    end

    def __index_some_things

      _attrs = @modifiers.get_derived_attributes__

      allers = nil
      eachers = nil

      _attrs.each do |attr|
        deri = attr.implementation.begin_deriver  # meh
        did = false
        if deri.respond_to? :see_and_or_mutate_for_derivation
          did = true
          ( eachers ||= [] ).push [ attr.implementation.derived_from, deri ]  # #here
        end
        if deri.respond_to? :apply_derivations
          did = true
          ( allers ||= [] ).push deri
        end
        did || fail
      end

      remove_instance_variable :@modifiers
      @__allers = allers
      @__eachers = eachers
      NIL
    end

    # ==

    Seer_via_deriver__ = -> key, deri do  # #here
      -> node do
        if node.box.has_name key
          deri.see_and_or_mutate_for_derivation node
        end
        NIL
      end
    end

    # ==
  end
end
