module Skylab::Brazen

  module Silo

    class Collection

      # intended as a long-running cache of any and every silo (daemon)
      # requested of the client kernel - each created lazily on request

      def initialize unb_mod, k

        @_bx = Common_::Box.new
        @_h = @_bx.h_
        @_kernel = k
        @_unbound_modules = unb_mod
      end

      def register_silo_daemon__ x, sym

        @_bx.add sym, x ; nil
      end

      def via_symbol sym, & x_p

        @_h.fetch sym do
          _id = Home_::Nodesque::Identifier.via_symbol sym
          via_identifier _id, & x_p
        end
      end

      def _via_resolved_identifier id

        _touch_via_silo_daemon_class_and_identifier(
          _silo_daemon_class_via_unbound( id.value ),
          id )
      end

      def via_normal_stream  st

        x = __via_normal_item st.gets_one
        if st.unparsed_exists
          x = x.silo_via_normal_stream st
        end
        x
      end

      def __via_normal_item const

        sym = const.downcase
        @_h.fetch sym do

          x = @_unbound_modules.const_get const, false

          _cls = if x.respond_to? :build_unordered_selection_stream
            _silo_daemon_class_via_unbound x
          else
            x.const_get DAEMON_CONST__, false
          end

          _add _cls, sym, x
        end
      end

      def via_identifier id, & x_p
        if id.is_resolved
          _via_resolved_identifier id, & x_p
        else
          __via_unresolved_identifier id, & x_p
        end
      end

      def __via_unresolved_identifier id, & p  # #note-40, :+[#pa-002]

        id = id.as_mutable_for_resolving

        full_raw_s_a = id.raw_name_parts

        index = -1
        last = full_raw_s_a.length - 1
        mod_a = nil
        node_x = @_kernel

        while index != last

          index += 1
          target_s = full_raw_s_a.fetch index

          if ! mod_a
            mod_a = __real_modules_array_via_unbound node_x, & p
            local_index = -1
          end

          local_index += 1
          __reduce_search_space mod_a, local_index, target_s

          case 1 <=> mod_a.length

          when  0
            node_x = mod_a.fetch 0
            _num_parts = _some_name_function_via_mod( node_x ).as_parts.length
            _start_of_next_part = index - local_index + _num_parts
            id.add_demarcation_index _start_of_next_part

            cls = _silo_daemon_class_via_unbound node_x

            if cls
              id.bake node_x
              x = _touch_via_silo_daemon_class_and_identifier cls, id
              break
            end
            mod_a = nil

          when  1
            x = __when_not_found id, target_s, & p
            break

          when -1
            # #note-265 - although it is a class of use cases for which this..
            NIL_
          end
        end
        x
      end

      def __when_not_found id, target_s, & p

        if p
          p.call :not_found do
            _build_model_not_found_event id, target_s
          end
        else
          raise _build_model_not_found_event( id, target_s ).to_exception
        end
      end

      def _build_model_not_found_event id, s

        Common_::Event.inline_with :node_not_found,
          :token, s, :identifier, id,
          :error_category, :name_error
      end

      def __reduce_search_space mod_a, local_index, target_s

        mod_a.each_with_index do |mod, d|
          s = _some_name_function_via_mod( mod ).as_parts[ local_index ]
          if ! ( s && target_s == s )
            mod_a[ d ] = nil
          end
        end

        mod_a.compact!

        NIL_
      end

      def _some_name_function_via_mod mod

        if mod.respond_to? :name_function
          mod.name_function
        else
          @_mod_nf_h ||= {}
          @_mod_nf_h.fetch mod do
            @_mod_nf_h[ mod ] = Common_::Name.via_module mod
          end
        end
      end

      def __real_modules_array_via_unbound unb, & p

        if unb.respond_to? :build_unordered_selection_stream

          # the above method is the universal way to detect a [normal]
          # unbound. despite this:

          _st = unb.build_unordered_real_stream( & p )

          _st.to_a  # or cover me

        else

          # it's very temping to use [etc] here as [#013] does, but
          # we hold off for now for reasons..

          self._COVER_ME
        end
      end

      def _touch_via_silo_daemon_class_and_identifier cls, id

        sym = id.silo_name_symbol
        @_h.fetch sym do
          _add cls, sym, id.value
        end
      end

      def _add cls, sym, unb
        x = cls.new @_kernel, unb
        @_bx.add sym, x
        x
      end

      def _silo_daemon_class_via_unbound unb

        unb.silo_module.const_get DAEMON_CONST__, false
      end
    end

    class Daemon

      # the silo's silo daemon can have any shape at all as long as it
      # constructs with the signature this class constructs by. this class,
      # then, is just a common choice for base class.

      def initialize kernel, silo_mod

        @kernel = kernel
        @silo_module = silo_mod

        if @kernel.do_debug
          @kernel.debug_IO.puts(
            ">>          MADE #{ Common_::Name.via_module( @silo_module ).as_slug } SILO" )
        end
      end

      def name_symbol
        @silo_module.name_function.as_lowercase_with_underscores_symbol
      end

      def call * x_a, & p
        bc = _bound_call_via x_a, & p
        bc and bc.receiver.send( bc.method_name, * bc.args )
      end

      def bound_call * x_a, & p
        _bound_call_via x_a, & p
      end

      def _bound_call_via x_a, & p

        o = Home_::Actionesque_ProduceBoundCall.new @kernel, & p
        o.iambic = x_a
        bound = @silo_module.new @kernel, & p
        o.current_bound = bound
        o.unbound_stream = bound.to_unordered_real_stream
          # real not, selection or index (for now)

        _ok = o.find_via_unbound_stream

        if _ok

          scn = o.argument_scanner
          h = { qualified_knownness_box: nil, preconditions: nil }
          until scn.no_unparsed_exists
            if :with == scn.head_as_is
              scn.advance_one
              break
            end
            k = scn.gets_one
            h.fetch k  # validate
            h[ k ] = scn.gets_one
          end
          preconds = h[ :preconditions ]
          qualified_knownness_box = h[ :qualified_knownness_box ]
          h = nil

          act = o.current_bound
          act.first_edit

          if preconds
            act.receive_starting_preconditions preconds
          end

          ok = true
          if qualified_knownness_box
            ok = act.process_qualified_knownness_box_passively__ qualified_knownness_box
          end

          ok &&= act.process_argument_scanner_fully st
          ok and act.via_arguments_produce_bound_call
        else
          o.bound_call
        end
      end

      # ~

      def any_mutated_formals_for_depender_action_formals x  # :+#public-API #hook-in

        # override this IFF your silo wants to add to (or otherwise mutate)
        # the formal properties of every client action that depends on you.

        my_name_sym = @silo_module.node_identifier.full_name_symbol

        a = @silo_module.preconditions
        if a and a.length.nonzero?
          x_ = x
          a.each do | silo_id |
            if my_name_sym == silo_id.full_name_symbol
              next
            end
            x__ = @kernel.silo_via_identifier( silo_id ).
              any_mutated_formals_for_depender_action_formals x_
            if x__
              x_ = x__
            end
          end
        end
        x_  # nothing by default
      end

      attr_reader(
        :silo_module,
      )
    end  # silo daemon class

    CONSTISH_RX = /\A[A-Z]/
    DAEMON_CONST__ = :Silo_Daemon
  end
end
