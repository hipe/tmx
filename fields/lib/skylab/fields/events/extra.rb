module Skylab::Fields

  module Events_Support_

    Home_::Events::Extra = Callback_::Event.prototype_with(

      :extra_properties,

      :name_x_a, nil,
      :did_you_mean_i_a, nil,
      :prefixed_conjunctive_phrase_context_proc, nil,
      :prefixed_conjunctive_phrase_context_stack, nil,
      :suffixed_prepositional_phrase_context_proc, nil,
      :lemma, nil,
      :adj, nil,
      :invite_to_action, nil,
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

      s_a = o.name_x_a.map( & method( :ick ) )
      _lemma = o.lemma || DEFAULT_PROPERTY_LEMMA_
      a.push plural_noun s_a.length, _lemma

      a.push and_ s_a

      p = o.suffixed_prepositional_phrase_context_proc
      if p
        calculate a, o, & p
      end

      y << a.join( SPACE_ )

      if o.did_you_mean_i_a
        _s_a_ = o.did_you_mean_i_a.map( & method( :code ) )
        y << "did you mean #{ or_ _s_a_ }?"
      end
    end

    class Events::Extra

      class << self

        def build x_a, did_you_mean_x_a=nil
          if 1 == x_a.length
            Special_single_digle___.new( x_a.first, did_you_mean_x_a ).execute
          else
            new_via x_a, did_you_mean_x_a
          end
        end

        def via_strange x
          new_via [ x ]
        end

        def new_via_arglist a
          new_via( * a )
        end

        def new_via name_x_a, did_you_mean_i_a=nil, lemma=nil, adj=nil  # [br]

          new_with(
            :name_x_a, name_x_a,
            :did_you_mean_i_a, did_you_mean_i_a,
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
              @_strange_x_ = @strange_x
              @_exp_x_a = @expected
            end
          else
            @_strange_x_ = @strange_x
            @_exp_x_a = nil
          end

          Here_.new_via [ @_strange_x_ ], @_exp_x_a
        end

        def ___reduce_exp_i_a
          if @strange_x.respond_to? :id2name
            @_strange_x_ = @strange_x.id2name
            _exp_s_a = @expected.map( & :id2name )
            @_exp_x_a = Levenshtein___[ @length_limit, _exp_s_a, @_strange_x_ ]
          else
            @_strange_x_ = Home_.lib_.strange @strange_x
            @_exp_x_a = exp_i_a[ 0, @length_limit ]
          end
        end
      end

      Levenshtein___ = -> closest_d, good_x_a, strange_x do  # #curry-friendly

        Home_.lib_.human::Levenshtein.with(
          :item, strange_x,
          :closest_N_items, closest_d,
          :items, good_x_a,
          :aggregation_proc, -> x_a do
            x_a  # just saying hello
          end,
          :item_proc, -> x do
            x  # ibid
          end,
        )
      end

      Here_ = self
    end
  end
end
