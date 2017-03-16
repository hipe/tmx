require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - misc meta attributes one" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes_entity_killer_methods

      context "`ivar`" do

        Attributes[ self ]

        given_the_attributes_ do
          attributes_(
            shenkberger: [ :ivar, :@_wazoo ],
          )
        end

        it "hi." do
          against_ :shenkberger, :_hey_
          @_wazoo.should eql :_hey_
        end
      end

      context "`custom_interpreter_method`" do

        Attributes[ self ]

        given_the_attributes_ do

          attributes_(
            zizzie: :custom_interpreter_method,
            zozlow: :custom_interpreter_method,
          )
        end

        shared_subject :_some_class_over_here do

          class X_a_ma_CW

            def zizzie=
              scn = @_argument_scanner_
              @zizzie = [ :_yes_, scn.gets_one, scn.gets_one ]
              true  # KEEP_PARSING_
            end

            attr_reader :zizzie

            self
          end
        end

        it "if the session object responds to it then yay" do

          sess = _some_class_over_here.new
          _attrs = the_attributes_
          _attrs.init sess, [ :zizzie, :wiffie, :skiffie ]
          sess.zizzie.should eql [ :_yes_, :wiffie, :skiffie ]
        end

        it "if the session does not respond then you get no grace" do

          sess = _some_class_over_here.new
          _attrs = the_attributes_

          begin
            _attrs.init sess, [ :zozlow, :_never_written ]
          rescue ::NoMethodError => e
          end

          e.message.should match %r(\Aundefined method `zozlow=')
        end
      end

      context "`custom_interpreter_method_of`" do

        Attributes::Meta_Attributes[ self ]

        shared_subject :entity_class_ do

          class X_a_ma_CIMO_A

            ATTRIBUTES = Attributes::Meta_Attributes.lib.call(
              zing: [ :custom_interpreter_method_of, :zung ],
            )

            def zung scn
              @_a_ = scn.gets_one
              @_b_ = scn.gets_one
              true  # ACHIEVED_
            end

            def _hi
              [ @_a_, @_b_ ]
            end

            self
          end
        end

        it "x." do

          _o = build_by_init_ :zing, :la, :lah
          _o._hi.should eql [ :la, :lah ]
        end
      end

    # ==

    context "(E.K)" do

      it "use any arbitrary normalization proc" do

        # :#coverpoint1.1 the first tail leg (disassociated)

        _subject = __this_one_subject_not_memoized_but_could_be
        2 == _subject.length || fail

        foo, bar = _subject

        foo.name_symbol == :foo || fail
        bar.name_symbol == :bar || fail

        foo.normalize_by || fail

        foo.normalize_by[ :xx ] == [ :_hi_from_FI_, :xx ] || fail
      end

      def __this_one_subject_not_memoized_but_could_be

        given_definition_(
          :property, :foo, :normalize_by, -> x { [ :_hi_from_FI_, x ] },
          :property, :bar
        )

        flush_to_item_stream_expecting_all_items_are_parameters_.to_a
      end

      context "use this one \"macro\"" do

        it "yes" do

          _attr = _attribute
          _qkn = Common_::QualifiedKnownness.via_value_and_symbol( -2, :_no_see_FI_ )
          _kn = _attr.normalize_by[ _qkn ]
          _kn.value_x == -2 || fail
        end

        it "no" do

          _attr = _attribute

          _qkn = Common_::QualifiedKnownness.via_value_and_symbol( -3, :_no_see_FI_ )

          chan = nil ; ev_p = nil

          _kn = _attr.normalize_by.call _qkn do |*a, &p|
            chan = a ; ev_p = p ; :_no_see_FI_
          end

          _kn == false || fail

          chan == [ :error, :invalid_property_value ] || fail

          _ev = ev_p[]

          _expag = my_all_purpose_expression_agent_

          _act = _ev.express_into_under "", _expag

          _act == "«prp: _no_see_FI_» must be greater than or equal to «val: -2», had «ick: -3»" or fail
        end

        shared_subject :_attribute do

          given_definition_(
            :property, :foo, :must_be_integer_greater_than_or_equal_to, -2,
          )
          flush_to_item_
        end
      end
    end

    # ==
    # ==
  end
end
