require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] CMA - intro" do  # :#cov2.1

    TS_[ self ]
    use :memoizer_methods
    use :attributes

    context "(context)" do

      given_the_attributes_ do

        attributes_(
          awesome: :flag,
          do_ignore_case: :known_known,
          ignore_case: [ :flag_of, :do_ignore_case ],
          path: [ :singular_of, :paths ],
          paths: nil,
        )
      end

      it "nothing" do
        against_ :paths, :hi
        expect( @paths ).to eql :hi
      end

      it "known known" do
        against_ :do_ignore_case, :momma
        kn = @do_ignore_case
        kn.is_known_known or fail
        expect( kn.value ).to eql :momma
      end

      it "flag" do
        against_ :awesome
        @awesome or fail
      end

      it "flag of" do  # :#coverpoint1.6

        against_ :ignore_case
        kn = @do_ignore_case
        kn.is_known_known or fail
        kn.value or fail
      end

      it "singular of" do

        against_ :path, :xx
        expect( @paths ).to eql [ :xx ]
      end
    end

    context "(context 2)" do

      given_the_attributes_ do

        attributes_(
          ruby_regexp: :optional,
        )
      end

      it "setting it works" do
        against_ :ruby_regexp, :hi
        expect( @ruby_regexp ).to eql :hi
      end

      it "but when it is not set.." do
        against_
        expect( instance_variable_defined? :@ruby_regexp ).to eql true
        expect( @ruby_regexp ).to be_nil
      end
    end

    context "an unrecognized meta-attribute" do

      given_the_attributes_ do

        attributes_(
          zoozie: :floozie_poozie,
        )
      end

      it "does not fail at definition time" do
        the_attributes_
      end

      it "does fail (raises exception) at definition parsing time" do  # :#cov2.11 (1x)

        attrs = the_attributes_

        _rx = /\Ainvalid meta association 'floozie_poozie', expecting \{ #{
          }[a-z_]+(?: \| [a-z_]+){3,20} \}\z/

        begin
          attrs.association_index
        rescue Home_::ArgumentError => e
        end

        s_a = e.message.split NEWLINE_
        s_a.first == "unrecognized meta-association 'floozie_poozie'." || fail
        s_a.last =~ /\Adid you mean :/ || fail
      end
    end

    # ==

    context "(E.K)" do

      it "parses two properties" do
        _subject.length == 2 || fail
      end

      it "names look good" do
        _subject.map( & :name_symbol ) == %i( foo bar ) || fail
      end

      it "properties know whether they are required" do
        a = _subject
        a.first.is_required && fail
        a.last.is_required || fail
      end

      shared_subject :_subject do

        given_definition_(
          :property, :foo,
          :required, :property, :bar,
        )

        _st = flush_to_item_stream_expecting_all_items_are_parameters_
        _st.to_a
      end
    end

    # ==
    # ==
  end
end
