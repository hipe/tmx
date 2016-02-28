module Skylab::Human

  module NLP::EN

    module Methods  # [#032]

      class << self

        def _call mod, * x_a
          if x_a.length.zero?
            mod.include self
          else
            edit_module_via_iambic mod, x_a
          end
        end

        alias_method :[], :_call
        alias_method :call, :_call
      end  # >>

      define_method :an, EN_[ :an ]

      define_method :s, EN_[ :s ]

      # this is its hacky power:
      #
      #   "#{ s a, :no }known person#{ s a } #{ s a, :is } #{ and_ a }".strip
      #
      # note there is redundancy with passing the `a` argument multiple times.
      #
      # the extended form of this is concerned with mitigating that redundancy:

      # (don't add constants to the client module)

      _COLLECTION = nil
      _NMN = nil
      _SLL = nil

      define_singleton_method :edit_module_via_iambic do | mod, x_a |

        # (for now the syntax is a mirage until we need it to be fuller)

        2 == x_a.length or raise ::ArgumentError,  __say_two( x_a )

        case x_a.first
        when :private
          do_private = true
        when :public
        else
          raise ::ArgumentError, __say_visibility( x_a.first )
        end

        mod.module_exec do

          write = if do_private
            -> sym do
              define_method sym, _COLLECTION[ sym ]
              private sym
            end
          else
            -> sym do
              define_method sym, _COLLECTION[ sym ]
            end
          end

          x_a.fetch( -1 ).each( & write )
          define_method :_NLP_normalize_and_memoize_numerish, _NMN
          define_method :_set_NLP_last_length_, _SLL

        end
      end

      class << self

        def __say_visibility x
          "public or private, not: '#{ x }'"
        end

        def __say_two x_a
          "#{ x_a.length } for 2"
        end
      end  # >>

      _COLLECTION = -> do  # define all the methods

        method_name_a = []
        method_proc_a = []

        o = -> sym, p do
          method_name_a.push sym
          method_proc_a.push p
          NIL_
        end

        class << o
          alias_method :[]=, :call
        end

        %i| an an_ |.each do | sym |

          o[ sym ] = -> lemma, x=false do

            _x_ = _NLP_normalize_and_memoize_numerish x
            EN_[ sym ][ lemma, _x_ ]
          end
        end

        o[ :_and ] = -> a do  # (when you want the leading space conditionally on etc)

          s = and_ a
          if s
            "#{ SPACE_ }#{ s }"
          else
            s
          end
        end

        _Memoize_length__ = -> & p do

          -> a do
            _set_NLP_last_length_ a.length
            instance_exec a, &p
          end
        end

        o[ :both ] = _Memoize_length__.call do | a |
          EN_.both a
        end

        o[ :indefinite_noun ] = -> lemma_s do

          EN_::POS.indefinite_noun lemma_s
        end

        o[ :_non_one ] = -> x=nil do  # for nlp hacks, leading space iff not 1

          x_ = _NLP_normalize_and_memoize_numerish x
          if 1 != x_
            "#{ SPACE_ }#{ x_ }"
          end
        end

        o[ :noun_phrase ] = -> * x_a do

          x_a.push :syntactic_category, :noun_phrase
          _fr = EN_.expression_frame_via_iambic x_a
          _fr.express_into ""
        end

        o[ :plural_noun ] = -> count_d=nil, lemma_s do

          EN_::POS.plural_noun count_d, lemma_s
        end

        o[ :preterite_verb ] = -> lemma_s do

          EN_::POS.preterite_verb lemma_s
        end

        o[ :progressive_verb ] = -> lemma_s do

          EN_::POS.progressive_verb lemma_s
        end

        o[ :s ] = -> * args do  # [length] [lexeme_i]

          len_x, lexeme_sym = Home_.lib_.parse.parse_serial_optionals(

            args,
            -> x { ! x.respond_to? :id2name },  # defer it
            -> x { x.respond_to? :id2name },
          )

          lexeme_sym ||= :s

          # when `len_x` is nil it means "use memoized"

          if :identity == lexeme_sym

            _NLP_normalize_and_memoize_numerish len_x
          else

            _x_ = _NLP_normalize_and_memoize_numerish len_x
            EN_.s _x_, lexeme_sym
          end
        end

        o[ :sentence_phrase_via_mutable_iambic ] = -> x_a do

          x_a.push :syntactic_category, :sentence_phrase
          _fr = EN_.expression_frame_via_iambic x_a
          _fr.express_into ""
        end

        -> do
          o[ :and_ ] = _Memoize_length__.call do |a|
            EN_::Oxford_and[ a ]
          end

          o[ :or_ ] = _Memoize_length__.call do |a|
            EN_::Oxford_or[ a ]
          end
        end.call

        ::Struct.new( * method_name_a ).new( * method_proc_a )

      end.call

      _NMN = -> x do  # normalize and memoize numerish

        if x

          x_ = ( if x.respond_to? :length  # result

            x.length
          else
            x
          end )

          _set_NLP_last_length_ x_
          x_

        elsif false == x
          false
        else
          @__NLP_last_length__
        end
      end

      _SLL = -> x do  # set last length
        @__NLP_last_length__ = x ; nil
      end
    end
  end
end
