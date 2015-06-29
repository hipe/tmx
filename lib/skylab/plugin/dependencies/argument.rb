module Skylab::Plugin

  class Dependencies

    module Argument

      module Has_arguments

        def self.[] cls

          cls.include Constants_and_Instance_Methods___
          cls.extend Module_Methods___
          NIL_
        end
      end

      module Constants_and_Instance_Methods___

        ROLES = nil
        SUBSCRIPTIONS = [ :argument_bid_for ].freeze

        def argument_bid_for tok

          prp = self.class.__argument_index[ tok ]
          if prp
            Bid.new self, prp.arity_symbol
          end
        end

        def receive_term term, _bid
          send term.method_name, * term.args
        end
      end

      Bid = ::Struct.new :implementation, :arity_symbol, :implementation_x

      module Module_Methods___

        def __argument_index
          @___argument_index ||= __build_argument_index
        end

        def __build_argument_index

          bx = Callback_::Box.new
          self::ARGUMENTS.each_slice 4 do | kw, a_i, kw_, n_i |
            :argument_arity == kw or raise ::ArgumentError, Say_art___[ kw ]
            :property == kw_ or raise ::ArgumentError, Say_prp___[ kw_ ]
            prp = Formal_Argument___.new a_i, n_i
            bx.add prp.name_symbol, prp
          end
          bx.freeze
        end
      end

      Formal_Argument___ = ::Struct.new :arity_symbol, :name_symbol

      Say_art___ = -> kw do
        "'argument_arity' not #{ Strange__[ kw ] }"
      end

      Say_prp___ = -> kw do
        "'property' not #{ Strange__[ kw ] }"
      end

      Strange__ = -> x do
        Home_.lib_.basic::String.via_mixed x
      end

      class Demux

        attr_accessor :be_passive  # when a head token is encountered
          # for which no strategy is found, end parse without failure

        attr_writer(
          :pub_sub_dispatcher,
          :upstream,
        )

        def execute  # algorithm explained at [#007.G]

          kp = KEEP_PARSING_
          st = @upstream

          begin

            if st.no_unparsed_exists
              break
            end

            g = Bid_group[ st.current_token, @pub_sub_dispatcher ]
            if ! g

              if self.be_passive
                break
              end
              raise __build_exception_for_when_unparsed_exists
            end

            kp = ARITIES__.fetch( g.arity_symbol )._dispatch g, st
            kp or break

            redo
          end while nil

          kp
        end

        def __build_exception_for_when_unparsed_exists

          _ev = Home_.lib_.brazen::Property.build_extra_values_event(
            [ @upstream.current_token ] )

          _ev.to_exception
        end
      end

      Bid_group = -> tok, deps do

        g = nil

        deps.accept_by :argument_bid_for do | pl |

          bid = pl.argument_bid_for tok
          bid or next

          g ||= Bid_Group___.new tok
          g._receive_bid bid
        end
        g
      end

      class Bid_Group___

        attr_reader(
          :a,
          :arity_symbol,
        )

        def initialize tok

          @_p = -> bid do  # the first time it is called

            @arity_symbol = bid.arity_symbol

            @a = [ bid ]

            @_p = -> bid_ do # subsequent times it is called

              if @arity_symbol == bid_.arity_symbol
                @a.push bid_
                KEEP_PARSING_  # if used
              else
                raise Definition_Conflict, __say_arity_conflict( bid_ )
              end
            end
            KEEP_PARSING_  # if used
          end

          @_tok = tok
        end

        def length
          @a.length
        end

        def _receive_bid bid
          @_p[ bid ]
        end

        def __say_arity_conflict bid_

          p = -> bd do
            bd.implementation.class.name
          end

          bid = @a.fetch 0

          "the arity in the first encountered definition for #{
            }'#{ @_tok }' was '#{ bid.arity_symbol }', #{
             }but then encountered a definition with an arity of #{
              }'#{ bid_.arity_symbol }' #{
               }(respectively by #{ p[ bid ] } then #{ p[ bid_ ] })"
        end
      end

      # (the below is our take on "multiton pattern"..)

      Arity__ = ::Class.new ::Module  # will re-open below
      o = {}

      # •

      c = Arity__.new
      ARITY_ZERO____ = c
      o[ :zero ] = c
      class << c

        def _dispatch g, st

          _flag = Flag___.new st.gets_one
          _dispatch_term g, _flag
        end
      end

      class Flag___

        attr_reader :method_name, :name_symbol

        def initialize tok
          @method_name = :"receive__#{ tok }__flag"
          @name_symbol = tok
        end

        def args
          NIL_
        end

        def argument_arity
          :zero
        end
      end

      # •

      c = Arity__.new
      ONE_ARITY____ = c
      o[ :one ] = c
      class << c

        def _dispatch g, st

          _arg = Actual_Argument___.new st.gets_one, st.gets_one
          _dispatch_term g, _arg
        end
      end

      class Actual_Argument___

        attr_reader :args, :method_name, :name_symbol, :x

        def initialize tok, x

          @method_name = :"receive__#{ tok }__argument"
          @name_symbol = tok
          @args = [ x ]
        end

        def argument_arity
          :one
        end
      end

      # •

      c = Arity__.new
      ARITY_CUSTOM____ = c
      o[ :custom ] = c
      class << c

        def _dispatch g, st

          custom = Custom_Head___.new st.gets_one, st
          _verify g, custom.name_symbol
          bid = g.a.fetch 0
          _kp = bid.implementation.receive_term custom, bid
          _kp or raise ::ArgumentError  # make it more traceable for now
        end

        def _verify g, tok

          if 1 != g.length
            raise Definition_Conflict, Say_greedy__[ g.a, tok ]
          end
        end
      end

      class Custom_Head___

        attr_reader :args, :method_name, :name_symbol

        def initialize tok, st
          @args = [ st ]
          @name_symbol = tok
          @method_name = :"receive_stream_after__#{ tok }__"
        end

        def argument_arity
          :custom
        end
      end

      # •

      c = Arity__.new
      ARITY_HEAD____ = c
      o[ :argument_upstream_head ] = c
      class << c

        def _dispatch g, st

          if 1 == g.length

            g.a.fetch( 0 ).receive_head_of_argument_parser st
          else
            raise Definition_Conflict, Say_greedy__[ g.a, st.current_token ]
          end
        end
      end

      ARITIES__ = o

      # ~ support

      Dispatch_term = -> g, term do

        kp = KEEP_PARSING_

        g.a.each do | bid |
          kp = bid.implementation.receive_term term, bid
          kp or raise ::ArgumentError  # make these easier to trace for now
        end
        kp
      end

      class Arity__  # re-opening

        define_method :_dispatch_term, Dispatch_term

        def _verify _, __
          NIL_
        end
      end

      Say_greedy__ = -> bid_a, tok do

        p = -> bid do
          bid.implementation.class.name
        end

        "#{ bid_a[ 1 .. -1 ].map( & p ) * ' and ' } cannot also declare #{
          }that #{ 2 == bid_a.length ? 'it parses' : 'they parse' } #{  # or etc
           }'#{ tok }' because #{ p[ bid_a[ 0 ] ] } #{
            }has already declared a custom parser for it"
      end

      # ( end "multiton pattern" )
    end
  end
end
