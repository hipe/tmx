require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] custom meta associations - common plus custom" do

    # this is how you add custom meta associations to the "EK" common
    # association; a requirement for our legacy behemoth apps, and a
    # feature that would be nice to have available for future work if ever
    # we decide it's compelling to have custom meta associations there too.
    #
    # :[#007.6].

    # (see notes #here1 below explaining design considerations)

    TS_[ self ]
    use :memoizer_methods

    context "(this one)" do

      it "see the injection" do
        _the_injection
      end

      it "parse a property that uses our new meta-association" do

        asc = _gets_one_item :property, :ohai, :color, :red
        asc.name_symbol == :ohai || fail
        asc.the_color == :red || fail
      end

      it "we didn't break things - you can still parse a common meta-association" do

        asc = _gets_one_item :property, :ohai, :default, :yep
        asc.name_symbol == :ohai || fail
        _kn = asc.default_by[]
        _kn.value == :yep || fail
      end

      shared_subject :_this_class do

        # :#here1:
        #
        # in practice there is always a need to be able to read the effects
        # of having defined something with a custom meta-association (here
        # "m.a"), and there is always a need to define some kind of new
        # reader method(s) to do so.
        #
        # (in theory it might be the case that your custom m.a only defines
        # a new way to write to an existing m.a but in practice this is
        # never useful.)
        #
        # as such you will want a new, custom association class to model
        # the reading of this or these new m.a's.
        #
        # again in practice it is always the case that we want to re-use the
        # set of common m.a's in our "stack" too, so this is one of the few
        # cases where we feel truly justified in subclassing anything:

        class X_cma_cpc_X1_Param < Home_::CommonAssociation::EntityKillerParameter

          define_singleton_method :grammatical_injection, ( Lazy_.call do

            # - name your postfixed (or prefixed) modifiers module anything.
            #   all that matters is that you pass it in as an argument to
            #   the injection we create below.
            #
            # - if you still want to support the common meta-associations
            #   as well as your custom ones (in practice this is always yes),
            #   then the (sublimely intuitive and) only way to do this is to
            #   include the appropriate common module into your custom module
            #   (prefixed with prefixed and postfixed with postfixed).
            #
            # - the only way to reach the common prefixed and postfixed
            #   modifiers modules is (currently) through the injection
            #   instance of the common association class (the counterpart
            #   to what we are making here); also intuitive in its way.
            #
            # - you don't have to create your custom module(s) inside a
            #   lazy block such as this, but doing so as we have done so
            #   here allows us to load not just our own injection but the
            #   remote injection lazily as well, which might tighten things
            #   up. but the only reason this is OK is because this whole
            #   block is a true memoization, so we are guaranteed that our
            #   creation of the module below only ever happens once.

            orig = superclass.grammatical_injection

            mod = module PrefixedModifiers_NO_SEE

              def color
                @parse_tree.__receive_color_ @scanner.gets_one
              end
              self
            end

            mod.include orig.postfixed_modifiers

            orig.redefine do |o|
              o.item_class = self
              o.postfixed_modifiers = mod
            end
          end )

          def __receive_color_ sym
            @_the_color = :__color
            @__color = sym
            KEEP_PARSING_  # #important
          end

          def the_color
            send @_the_color
          end

          def __color
            @__color
          end

          self
        end
      end
    end

    def _gets_one_item * sym_a
      _inj = _the_injection
      _inj.gets_one_item_via_scanner_fully Scanner_[ sym_a ]
    end

    def _the_injection
      _this_class.grammatical_injection
    end
  end
end
