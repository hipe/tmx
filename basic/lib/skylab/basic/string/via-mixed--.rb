module Skylab::Basic

  module String

    module ViaMixed__  # :[#019] #:+[#hu-002] summarization (trivial)

      # conceptually similar to sending `inspect` to some mystery value
      # but has some specialized behavioral "consequences" for certain
      # "shape categories" - for example if the mixed value is a string
      # and it is beyond some certain length, the result is ellipsified.
      #
      # this specialized behavior is itself configurable to a certain
      # degree, and it can be exposed arbitrarily further as needed.

      class << self

        def call_via_arglist a
          if a.length.zero?
            POLICY__
          else
            POLICY__.against( * a )
          end
        end
      end  # >>

      class Policy___

        class << self
          alias_method :define, :new
          undef_method :new
        end  # >>

        def initialize hm
          yield self
          @_hook_mesh = hm  # (or before the yield, when needed)
          freeze
        end

        def initialize_copy _
          NOTHING_  # hi. :#here
        end

        # -- (re) define

        # :#here:

        def non_long_string_by= inspect_p
          __receive_hook_mutation :non_long_string, inspect_p
        end

        def __receive_hook_mutation hook_sym, inspect_p  # assume..

          # we assume this is a mutable dup (deprecated). (if it is not the
          # below ivar assignment will fail.) we make the deep dup of the
          # hook mesh only lazily (if it is actually necessary) instead of
          # doing it eagerly (and occasionally wastefully) #here.

          if @_hook_mesh.frozen?
            @_hook_mesh = @_hook_mesh.dup
          end

          @_hook_mesh.replace hook_sym do |o|
            inspect_p[ o.value ]
          end

          NIL
        end

        # ~

        attr_writer(
          :max_width,
        )

        # -- apply

        def to_proc

          # (you can't just say `method :against` - result must be an actual
          # proc so that it can be used as an argument to `define_method`.)
          # (covered by [st])

          me = self
          -> x do
            me.against x
          end
        end

        def against x
          @_hook_mesh.against_value_and_choices x, self
        end

        attr_reader(
          :max_width,
          :value,
        )
      end

      _orig = Home_::OMNI_TYPE_CLASSIFICATION_HOOK_MESH_PROTOTYPE

      _hook_mesh = _orig.redefine do |defn|

        defn.replace :falseish do |o|
          o.when( :default )[ o ]
        end

        defn.add :symbol do |o|
          o.when( :default )[ o ]
        end

        defn.add :true do |o|
          o.when( :default )[ o ]
        end

        defn.add :zero do |o|
          o.when( :default )[ o ]
        end

        defn.replace :numeric do |o|
          o.when( :default )[ o ]
        end

        defn.replace :string do |o|

          if o.choices.max_width < o.value.length
            o.when( :long_string )[ o ]
          else
            o.when( :non_long_string )[ o ]
          end
        end

        defn.add :non_long_string do |o|
          o.when( :default )[ o ]
        end

        defn.add :long_string do |o|

          _moniker = String_.ellipsify o.value, o.choices.max_width

          o.when( :default )[ o.new_with_value( _moniker ) ]
        end

        _simple_rx = /\A[[:alnum:] _]+\z/

        defn.replace :symbol do |o|

          sym = o.value
          if _simple_rx =~ sym
            "'#{ sym.id2name }'"
          else
            sym.inspect
          end
        end

        defn.add :other do |o|

          x = o.value
          if x.respond_to? :class
            "< a #{ x.class } >"
          else
            '???'
          end
        end

        defn.add :default do |o|
          o.value.inspect
        end
      end

      POLICY__ = Policy___.define _hook_mesh do |o|

        o.max_width = A_REASONABLY_SHORT_LENGTH_FOR_A_STRING_
      end
    end
  end
end
# #history: full overhaul to use "hook mesh"
