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

      Component_Added = Callback_::Event.prototype_with(  # :+[#035]:D

        :component_added,
        :component, nil,
        :component_association, nil,
        :ACS, nil,

        :ok, true,

      ) do | y, ev |

        o = Event_Support_::Expresser[ self, ev ]

        _verb_sym = :add  # :+[#035]:WISH-A
        _s = Home_.lib_.human::NLP::EN::POS::Verb[ _verb_sym.to_s ].preterite

        o.instance_exec do

          say _s
          express_component or say 'component'

          if @can_express_collection_related_ && ! @did_express_context_chain_
            say 'to'
            express_collection
          end

          flush_into y
        end
      end

      Component_Removed = Callback_::Event.prototype_with(  # [#035]:B

        :component_removed,
        :component, nil,
        :component_association, nil,
        :ACS, nil,

        :is_completion, true,  # remember this? hehe
        :ok, true

      ) do | y, o |

        o = Event_Support_::Expresser[ self, o ]

        o << 'removed'  # one day [#035]:WISH-A
        o.express_component or say 'component'
        o << 'from'
        o.express_collection or say 'collection'
        o.flush_into y
      end
    end
  end

  module Event_Support_  # publicize if needed. stowaway.

    SubPhrase_Methods__ = ::Module.new

    module Expresser

      include SubPhrase_Methods__

      # although an event object itself is immutable, it is convenient for
      # the sake of complex expression strategies to use "session pattern"
      # on a object that is of the same structure and content but mutable

      def self.[] expag, ev
        o = ev.dup.extend self
        o.initialize_as_expresser expag
        o
      end

      def initialize_as_expresser expag

        @expag_ = expag  # before next
        __index_component_association_related
        index_component_related
        __index_collection_related
        init_expresser_list
        NIL_
      end

      # ~ indexing

      def __index_component_association_related

        asc = @component_association
        if asc

          # if x is linked-list-friendly (nf or ca), get to the back of it

          if asc.respond_to? :next

            back = asc.next
            if back
              context_chain = [ asc ]
              begin
                context_chain.push back
                asc = back
                back = back.next
                back or break
                redo
              end while nil
            end
          end

          # after that:

          if asc.respond_to? :component_model  # original, "real" asc from ACS
            cm = asc.component_model

          elsif asc.respond_to? :module_exec  # to sneak in only the model class
            cm = asc
            asc = nil
          end

          if context_chain  # experimental

            expressed_context_chain = true

            _s_a = context_chain.reduce [] do | m, x |
              s = x.description_under @expag_
              s and m.push s
              m
            end

            ca_s = _s_a * SPACE_

          elsif asc
            ca_s = asc.description_under @expag_
          end
        end

        if cm
          cm_s = __determine_component_model_string_via_component_model cm
        end

        @component_association_string_ = ca_s
        @component_model_string_ = cm_s
        @did_express_context_chain_ = expressed_context_chain
        NIL_
      end

      def index_component_related

        if @component
          cmp_s = describe_component @component
        end

        @can_express_component_related_ = (
          cmp_s ||
          @component_association_string_ ||
          @component_model_string_ ) && true

        @can_express_component_ = cmp_s && true
        @component_string_ = cmp_s
        NIL_
      end

      def __determine_component_model_string_via_component_model mdl

        # any module-looking models that want to opt-out of the below
        # default behavior must implement the below method as nil

        nf = if mdl.respond_to? :name_function
          mdl.name_function

        elsif mdl.respond_to? :module_exec

          Callback_::Name.via_module mdl
        end

        if nf
          nf.as_human
        end
      end

      def __index_collection_related

        # this feels like an inappropriate amound of detail to index at this
        # level, but it is a glint at something deeper we are developing; and
        # it is for now necessary to have it here to faithfully abstract
        # surface structures from our real-world targets:
        #
        # filesystem paths (notwithstanding relative) are generally longer
        # than one "word" so we find that it flows better to use a structure
        # that gets them at the very end of the expression rather than
        # anywhere else. (indeed, this idea came from platform exception
        # messages.) compare:
        #
        #     "<model> does not have <component> - <long path>"
        # vs.
        #
        #     "<model> <long path> does not have <component>"
        #
        # when faced with a path-looking surface expression for the
        # collection, the expresion-building client may want to chose a
        # structure that is like the first form with the path cojoined by
        # a hyphen in its own phrase, rather than the second form that
        # places the full collection string as the agent of the sentence.
        #
        # we started [#hu-044]:1 to explore this

        acs = @ACS
        if acs

          if acs.respond_to? :description_under
            acs_s = acs.description_under @expag_

            if acs_s
              looks_like_FN = acs_s.include? ::File::SEPARATOR

            end
          end

          acs_model_s = begin

            nf = if acs.respond_to? :name
              acs.name
            else
              Callback_::Name.via_module acs.class
            end

            if nf
              nf.as_human
            end
          end
        end

        @can_express_collection_related_ = ( acs_s || acs_model_s ) && true

        @can_express_collection_ = acs_s && true
        @collection_model_string_ = acs_model_s
        @collection_string_ = acs_s
        @collection_string_looks_like_filename_ = looks_like_FN
        NIL_
      end

      # ~ higher-level "macros"

      def express_component

        say_unique(
          @component_model_string_,
          @component_association_string_,
          @component_string_,
        )
      end

      def say_component cmp
        say describe_component cmp
      end

      def describe_component cmp
        cmp.description_under @expag_
      end

      def express_collection

        say_unique(
          @collection_model_string_,
          @collection_string_,
        )
      end

      # ~ style support

      def style_as_ick_if_necessary s
        Ick_if_necessary_of_under___[ s, @expag_ ]
      end

      # ~ "sub-phrase" & related

      def new_subphrase
        SubPhrase___.new
      end

      def say_by & p
        say_any @expag_.calculate( & p )
      end

      def flush_into y
        y << remove_instance_variable( :@_a ).join( SPACE_ )
      end
    end

    class SubPhrase___

      include SubPhrase_Methods__

      def initialize
        init_expresser_list
      end
    end

    module SubPhrase_Methods__

      def init_expresser_list
        @_a = [] ; nil
      end

      def maybe_say & p
        d = list_length
        instance_exec( & p )
        d != list_length
      end

      def say_unique * s_a

        # given a list of N surface expression strings going from general
        # to specific (e.g "human", "user", "Jaako"), express each one in
        # order after having de-duped the items in this way:

        # for any two would-be contiguous items that have a redundancy where
        # the more general item alreay expressed at the *tail* of the more
        # specific item, omit the expression of the general item:

        #     "foo", "foo", "bar"         => "foo", "bar",
        #     "color", "background color" => "background color"
        #     "user", "super-user"        => "super-user"
        #   ~ "user", "superuser"

        raw_st = Callback_::Polymorphic_Stream.via_array s_a

        st = Callback_.stream do  # ignore empties

          begin
            raw_st.no_unparsed_exists and break
            s = raw_st.gets_one
            s ? break : redo
          end while nil
          s
        end

        general_s = st.gets
        if general_s

          did_any = true

          begin

            specific_s = st.gets

            if ! specific_s
              say general_s
              break
            end

            rx = /\b#{ ::Regexp.escape general_s }\z/

            if rx !~ specific_s
              say general_s
            end
            general_s = specific_s
            redo
          end while nil
        end

        did_any
      end

      def say_via_nonsparse_array a
        @_a.concat a ; nil
      end

      def say_any s
        if s
          say s
        end
      end

      def << s  # prettier when used as session
        say s
        self
      end

      def say s
        @_a.push s
        ACHIEVED_
      end

      def list_length
        @_a.length
      end

      def list
        @_a
      end

      def flush_into_list a
        a.concat flush_to_array
        NIL_
      end

      def flush_to_array
        remove_instance_variable :@_a
      end
    end

    rx = nil
    Ick_if_necessary_of_under___ = -> s, expag do
      rx ||= /\A['"(]/
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
