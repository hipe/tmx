module Skylab::Brazen

  # the purpose of this file is exactly twofold. it is:
  #
  #   1) to define the eponymous module (because it must)
  #
  #   2) to define a support module that many client event modules
  #      will pull in using 'the trick'
  #
  # (but while we are at it we stowaway "small" event prototypes here too)


  Autoloader_[ Events_ = ::Module.new ]

  module Event_Support_

    module Home_::Events_

      Entity_Already_Added = Callback_::Event.prototype_with(  # :+[#035]:C

        :entity_already_added,

        :entity, nil,
        :entity_collection, nil,

        :error_category, :key_error,
        :ok, false

      ) do | y, o |

        a = []
        subject = o.entity_collection.description_under self
        subject and a.push subject

        a.push 'already'

        conjugated_verb = 'has'  # (one day [#015])
        a.push conjugated_verb

        object = o.entity.description_under self
        object and a.push object

        y << ( a * SPACE_ )
      end

      Entity_Added = Callback_::Event.prototype_with(  # :+[#035]:D

        :entity_added,

        :entity, nil,
        :entity_collection, nil,

        :verb_symbol, :add,

        :ok, true

      ) do | y, o |

        _s = Home_.lib_.human::NLP::EN::POS::Verb[ o.verb_symbol.to_s ].preterite

        a = [ _s ]

        s = o.entity.description_under self
        if s
          a.push s
        end

        acs = o.entity_collection
        s = acs.description_under self
        if ! s
          s = acs.name.as_human
        end
        a.push 'to'
        a.push s

        y << ( a * SPACE_ )

        NIL_
      end

      def __WAS__verb_i
        @do_prepend ? :prepend : :append
      end

      Entity_Removed = Callback_::Event.prototype_with(  # [#035]:B

        :entity_removed,
        :component, nil,
        :component_association, nil,
        :ACS, nil,

        :is_completion, true,  # remember this? hehe
        :ok, true

      ) do | y, o |

        o = Event_Support_::Expresser[ self, o ]

        o << 'removed'  # (one day [#035]:WISH-A EN-like expression adapters)
        o.express_referent
        o << 'from'
        o.express_collection
        o.flush_into y
      end
    end
  end

  module Event_Support_  # publicize if needed. stowaway.

    module Expresser

      # although an event object itself is immutable, it is convenient for
      # the sake of this complex expression to use "session pattern" on a
      # object that is of the same structure and content but is mutable so:

      def self.[] expag, o
        o.dup.extend( self ).__init expag
      end

      def __init expag
        @_a = []
        @expag_ = expag
        self
      end

      def << s
        _accept s ; self
      end

      def express_referent

        resolve_association_related_

        d = _current_length

        _ = determine_component_model_string_
        _accept_unique _, @asc_s_

        _accept_any determine_component_string_

        if d == _current_length
          _accept 'component'
        end
        NIL_
      end

      def express_collection

        d = _current_length

        _ = determine_ACS_model_string_
        __ = determine_ACS_string_
        _accept_unique _, __

        if d == _current_length
          _accept 'collection'
        end

        NIL_
      end

      def determine_component_model_string_

        mdl = @component_model_
        if mdl
          nf = if mdl.respond_to? :name_function
            mdl.name_function
          elsif mdl.respond_to? :module_exec
            Callback_::Name.via_module mdl
          end
          if nf
            nf.as_human
          end
        end
      end

      def determine_component_string_

        if @component
          @component.description_under @expag_
        end
      end

      def resolve_association_related_

        # resolve any component model and any string

        asc = @component_association

        if asc.respond_to? :component_model  # original, "real" asc from ACS
          cm = asc.component_model

        elsif asc.respond_to? :module_exec  # to sneak in only the model class
          cm = asc
          asc = nil
        end

        if asc
          s = asc.description_under @expag_
        end

        @asc_s_ = s
        @component_model_ = cm
        NIL_
      end

      def determine_ACS_model_string_

        acs = @ACS
        if acs
          nf = if acs.respond_to? :name
            acs.name
          else
            Callback_::Name.via_module acs.class
          end
        end

        if nf
          nf.as_human
        end
      end

      def determine_ACS_string_
        acs = @ACS
        if acs
          acs.description_under @expag_  # might come out nil
        end
      end

      def _accept_unique s, s_

        if s
          if s_
            if s == s_
              _accept s
            else
              _accept s
              _accept s_
            end
          else
            _accept s
          end
        elsif s_
          _accept s_
        end
      end

      def _accept_any s
        if s
          _accept s
        end
      end

      def _accept s
        @_a.push s ; nil
      end

      def _current_length
        @_a.length
      end

      def flush_into y
        y << @_a.join( SPACE_ )
      end
    end

    rx = nil
    Ick_if_necessary_of_under = -> s, expag do
      rx ||= /\A['"]/
      if rx =~ s
        s
      else
        expag.calculate do
          ick s
        end
      end
    end
  end
end
