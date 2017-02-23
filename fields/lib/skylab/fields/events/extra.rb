module Skylab::Fields

  module Event_

    Home_::Events::Extra = Common_::Event.prototype_with(

      :extra_properties,

      :name_x_a, nil,
      :did_you_mean_symbol_array, nil,
      :prefixed_conjunctive_phrase_context_proc, nil,
      :prefixed_conjunctive_phrase_context_stack, nil,
      :suffixed_prepositional_phrase_context_proc, nil,
      :lemma, nil,  # string or symbol OK
      :adj, nil,
      :invite_to_action, nil,
      :exception_class_by, -> { Home_::ArgumentError },
      :error_category, :argument_error,
      :ok, false,

    ) do |y, o|

      # e.g: "couldn't wizzle - unrecognized property 'foo' in blah blah"

      a = []
      p = o.prefixed_conjunctive_phrase_context_proc
      if p
        calculate a, o, & p
      end

      s = o.adj
      a.push s || "unrecognized"

      simple_inflection do

        # "unrecognized property 'mlem'" | "unrecogized properties 'mlem' and 'baz'"

        _scn = Scanner_[ o.name_x_a ]

        buff = oxford_join _scn do |x|  # determine the count
          ick_mixed x
        end

        a.push n ( o.lemma || DEFAULT_PROPERTY_LEMMA_ )  # use the count
        a.push buff
      end

      p = o.suffixed_prepositional_phrase_context_proc
      if p
        calculate a, o, & p
      end

      y << a.join( SPACE_ )

      sym_a = o.did_you_mean_symbol_array

      if sym_a
        _m = respond_to?( :code ) ? :code : :ick_mixed
        code = method _m

        simple_inflection do
          buff = "did you mean "
          oxford_join buff, Scanner_[ sym_a ], " or " do |sym|
            code[ sym ]
          end
          buff << "?"
          y << buff
        end
      end

      y
    end

    class Events::Extra

      class << self

        def build x_a, did_you_mean_x_a=nil
          if 1 == x_a.length
            Special_single_digle___.new( x_a.first, did_you_mean_x_a ).execute
          else
            new x_a, did_you_mean_x_a
          end
        end

        def via_strange x
          new [ x ]
        end

        def via_arglist a
          new( * a )
        end

        def new name_x_a, did_you_mean_i_a=nil, lemma=nil, adj=nil  # [br]  # a custom [#co-070.2]

          with(
            :name_x_a, name_x_a,
            :did_you_mean_symbol_array, did_you_mean_i_a,
            :lemma, lemma,
            :adj, adj,
          )
        end
      end  # >>

      class Special_single_digle___

        def initialize x, a

          @expected = a
          @length_limit = A_FEW___
          @strange_x = x
        end

        A_FEW___ = 3

        def execute
          if @expected
            if @expected.length > @length_limit
              ___reduce_exp_i_a
            else
              @_use_strange_x = @strange_x
              @_exp_x_a = @expected
            end
          else
            @_use_strange_x = @strange_x
            @_exp_x_a = nil
          end

          Here_.new [ @_use_strange_x ], @_exp_x_a
        end

        def ___reduce_exp_i_a
          if @strange_x.respond_to? :id2name
            @_use_strange_x = @strange_x.id2name
            _exp_s_a = @expected.map( & :id2name )
            @_exp_x_a = Levenshtein___[ @length_limit, _exp_s_a, @_use_strange_x ]
          else
            @_use_strange_x = Home_.lib_.strange @strange_x
            @_exp_x_a = exp_i_a[ 0, @length_limit ]
          end
        end
      end

      Levenshtein___ = -> closest_d, good_x_a, strange_s do  # #curry-friendly

        Home_.lib_.human::Levenshtein.via(
          :item_string, strange_s,
          :closest_N_items, closest_d,
          :items, good_x_a,
          :aggregate_by, -> x_a do
            x_a  # just saying hello
          end,
          :map_result_items_by, -> x do
            x  # ibid
          end,
        )
      end

      # ==
      # ==

      Here_ = self

      # ==
    end
  end
end
