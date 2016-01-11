module Skylab::SearchAndReplace

  class Interface_Models_::Search

    # #frontier(s) here (and prototyping eyeblood):
    #
    #   • subject is a  "dynamic compound" - its associations
    #     are determined entirely at "runtime" (as opposed to by method
    #     definitions).
    #
    #   • subject is a "component as model"s - it defines
    #     instance methods that are usually defined as methods on the class
    #     of same. it's a "hybrid" ..

    def initialize comp_a, & _IGNORING_oes_P

      # which interface nodes are active is determined from above.
      # #todo-at-end is it as open issue that this might go stale & out of sync w/
      # UI, but we can't cover that until much later..

      @_component_a = comp_a

      @functions_directory = nil
      @replacement_expression = nil
    end

    # .. you want it to look like a *compound* node so the parser recurses ..

    def interpret_compound_component p, & _oes_p_p
      p[ self ]
    end

    def to_stream_for_component_interface

      # for the components dynamically injected to us from above,
      # for now we must manaully build the associations for them

      _st = Callback_::Stream.via_nonsparse_array @_component_a

      _from_above = _st.map_by do | component |

        _nf = component.name_

        _asc = ACS_::Component_Association.via_name_and_model(
          _nf, component )

        Callback_::Qualified_Knownness.via_value_and_association(
          component, _asc )
      end

      _from_above.concat_by ___my_additional_associations
    end

    def ___my_additional_associations

      ACS_::For_Interface::Infer_stream[ self ]
    end

    def __replacement_expression__component_association

      # always from this frame the caller has the ability to specify a
      # replacement expression. (there's no real reason we don't add this
      # fieldlike component up above like others except for the "feeling"
      # that it belongs here.)

      -> st, & pp do
        if st.unparsed_exists
          Callback_::Known_Known[ st.gets_one ]
        end
      end
    end

    def __replace__component_association

      if @replacement_expression
        @replace ||= Replace_Model_Proxy___.new self  # ivar because we gotta..
      end
    end

    def __functions_directory__component_association

      -> st do
        if st.unparsed_exists
          Callback_::Known_Known[ st.gets_one ]
        end
      end
    end

    def __build_replacement_bound_call & pp

      # OK we're still figuring this out - because we form the counterpart
      # association's component model to look "entitesque", we want to
      # result in a bound call here? ..

      dependency = @_component_a.fetch( -1 )
        # yikes - randomly access a volatile UI structure to get a dependency

      if ! dependency.respond_to? :to_mutable_file_session_stream
        self._HARDCODED_OFFSET_CHANGED
      end

      o = Home_::Interface_Models_::Replace.new( & pp )
      o.functions_directory = @functions_directory
      o.streamer = dependency
      o.replacement_expression = @replacement_expression

      _bc = Callback_::Bound_Call[ nil, o, :to_file_session_stream ]

      _bc
    end

    class Replace_Model_Proxy___

      # the only reason that (for now) we have to make this bump is
      # because we want it to look entitesque and not primitivesque

      def initialize _
        @_guy = _
      end

      def interpret_component st, & pp
        if st.no_unparsed_exists
          @_guy.__build_replacement_bound_call( & pp )
        else
          self._RIDE_THIS_50_50_its_OK
        end
      end
    end

    Require_ACS_[]
  end
end
