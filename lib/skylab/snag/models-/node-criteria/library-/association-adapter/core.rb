module Skylab::Snag

  module Models_::Node_Criteria

    module Library_

      class Association_Adapter < Common_Adapter_

        Methodic_.call self, :simple, :properties,
          :required, :property, :verb_lemma

      private

        def named_functions=

          bx = Callback_::Box.new
          st = @__methodic_actor_iambic_stream__
          name_sym = st.gets_one
          func_sym = st.gets_one
          begin

            st_ = if :sequence == func_sym  # we change the syntax, experimentally
              _a = st.gets_one
              _a_= [ :functions, * _a ]
              Callback_::Polymorphic_Stream.new 0, _a_
            else
              st
            end

            _cls = Parse__.function func_sym

            _f = _cls.new_via_iambic_stream_passively st_

            bx.add name_sym, _f

            st.no_unparsed_exists and break
            name_sym = st.gets_one
            func_sym = st.gets_one
            redo
          end while nil

          @named_functions_ = bx

          KEEP_PARSING_
        end

      public

        def output_node_via_input_stream st, & x_p

          # spaghetti peek quite a bit before firing up a state machine

          x = DID_NOT_PARSE_
          if st.unparsed_exists

            d = scan_the_verb_token_ st

            if d  # is

              vmp = parse_a_verb_modifier_phrase_ st

              if vmp  # is pink

                d = st.current_index

                sym = parse_a_conjunctive_token_ st

                if sym  # is pink or

                  d_ = scan_the_verb_token_ st
                  vmp_ = parse_a_verb_modifier_phrase_ st

                  if d_  # is pink or is

                    if vmp_  # is pink or is green

                      x = __run_against_state_machine( :after_verb_phrase,
                        vmp, sym, vmp_, st, self, & x_p )

                    else # is pink «or is foo»
                      st.current_index = d
                      x = vmp
                    end
                  else

                    if vmp_  # is pink or green

                      x = __run_against_state_machine( :in_verb_modifier_phrase,
                        vmp, sym, vmp_, st, self, & x_p )

                    else  # is pink «or bleats»
                      st.current_index = d
                      x = vmp
                    end
                  end

                else  # is pink «gazoink»
                  x = vmp
                end

              else  # is «foo»
                st.current_index = d
              end
            end  # «bleats»
          end
          x
        end

        def __run_against_state_machine * a, & x_p

          AA_::State_Machine__.new( * a, & x_p ).execute
        end

        include Association_Parse_Functions_

        attr_reader :named_functions_, :verb_lemma

        Autoloader_[ self ]

        AA_ = self

        Parse__ = LIB_.parse_lib

      end

# ~
if false

    class Has_Tag < Tag_Related_

      def phrase
        "tag ##{ @valid_tag_stem_i }"
      end

      def match? node
        if node.is_valid
          @tag_rx =~ node.first_line_body or
          if node.extra_lines_count > 0
            node.extra_line_a.index { |x| @tag_rx =~ x }
          end
        end
      end
    end

    class Does_Not_Have_Tag < Has_Tag

      def phrase
        "without #{ super }"
      end

      def match? node
        ! super node
      end
    end

    class IdentifierRef

      class << self

        def normal sexp, delegate
          identifier_body = sexp[ 1 ]  # prefixes might bite [#019]
          normal = Models::Identifier.normal identifier_body, delegate
          normal and new normal
        end
      end

      def initialize identifier_o
        @identifier = identifier_o
        @identifier_rx = /\A#{ ::Regexp.escape @identifier.body_s }/  # [#019], :~+[#ba-015]
      end

      def phrase
        "identifier starting with \"#{ @identifier.body_s }\""
      end

      def match? node
        if node.is_valid
          @identifier_rx =~ node.identifier_body
        end
      end
    end
end
# ~


    end
  end
end
