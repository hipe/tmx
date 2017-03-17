require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] CMA - desc" do  # :#cov2.9

    TS_[ self ]
    use :memoizer_methods
    use :attributes_meta_associations

      context "(context)" do

        shared_subject :entity_class_ do

          class X_cma_Desc_A

            attrs = Attributes.lib.call(
              wazlow: [ :desc, -> y { y << "line 1: #{ self._hi }" ; y << "line 2" } ],
              pazlow: [ :desc, -> { "this way #{ self._hi }" } ],
            )

            ATTRIBUTES = attrs

            self
          end
        end

        it "multi line form" do

          _desc_lines_for( :wazlow ).should eql [ "line 1: _hello_", "line 2" ]
        end

        it "single line form" do

          _desc_lines_for( :pazlow ).should eql [ "this way _hello_" ]
        end
      end

      def _desc_lines_for k

        desc_p = attribute_( k ).description_proc

        if desc_p.arity.zero?
          [ _would_be_expression_agent.calculate( & desc_p ) ]
        else
          _would_be_expression_agent.calculate [], & desc_p
        end
      end

      memoize :_would_be_expression_agent do

        cls = class X_cma_Desc_Expag

          alias_method :calculate, :instance_exec

          def _hi
            :_hello_
          end

          self
        end

        cls.new
      end

    # ==

    it "(E.K)" do

        _subject = __subject

        _subject.length == 2 || fail

        _subject.map( & :name_symbol ) == %i( foo bar ) || fail

        a = _subject
        a.first.describe_by && fail
        a.last.describe_by[ [] ] == %w(hallo) || fail
    end

    def __subject

        given_definition_(
          :property, :foo,
          :property, :bar, :description, -> y do
            y << "hallo"
          end,
        )

        _st = flush_to_item_stream_expecting_all_items_are_parameters_
        _st.to_a
    end
    # ==
    # ==
  end
end
