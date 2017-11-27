require_relative '../sexp'

module Skylab::Basic::TestSupport

  # <-

describe "[ba] sexp - auto" do

  ::Skylab::TestSupport::Quickie.apply_experimental_specify_hack self

  TS_[ self ]
  use :the_method_called_let

  context "With a grammar for first names" do

    let :grammar do
      <<-HERE.unindent
        module Skylab::Basic::TestSupport
          grammar PersonName_01
            rule person_name
              [a-z]+ <Node>
            end
          end
        end
      HERE
    end

    it "(the treetop grammar parses inputs like normal)" do

      _ = parser.parse 'mary'

      expect( _ ).to be_kind_of _Treetop::Runtime::SyntaxNode

      _ = parser.parse 'joe bob'

      expect( _ ).to be_nil
    end

    it "parse trees get a method called 'sexp'" do

      _node = parser.parse 'mary'
      _node.sexp
    end

    context "it does nothing interesting with a not complex grammar" do

      context 'the sexp for the string "mary"' do

        let :input do
          'mary'
        end

        specify do
          should eql 'mary'
        end
      end
    end
  end

  context "With a grammar for first and last names" do

    def grammar

      <<-HERE.unindent
        module Skylab::Basic::TestSupport
          grammar PersonName_02
            rule person_name
              t_1_first:( [a-z]+ )
              n_2_last:(
                w_1:' '+
                t_3_body:( [a-z]+ )
              )?
              <Node>
            end
          end
        end
      HERE
    end

    it "(the treetop grammar parses inputs like normal)" do

      pa = parser

      _ = pa.parse 'mary'
      expect( _ ).to be_kind_of Home_::TestSupport::PersonName_02::Node

      _ = pa.parse 'joe bob'
      expect( _ ).to be_kind_of Home_::TestSupport::PersonName_02::Node

      _ = pa.parse 'joe bobo briggs'
      expect( _ ).to be_nil
    end

    context "because the grammar is more complex, stuff starts to happen magically" do

      context 'the sexp for the string "mary"' do

        def input
          "mary"
        end

        def expected
          [ :person_name, [ :first, "mary" ], [ :last, '' ] ]
        end

        specify do
          should eql expected
        end

        specify do
          should be_kind_of Home_::Sexp
        end
      end

      context 'the sexp for the string "joe bob" (note it is sub-optimal)' do

        def input
          'joe bob'
        end

        def expected
          [ :person_name, [ :first, "joe" ], [ :last, " bob" ] ]
        end

        specify do
          should eql expected
        end
      end
    end
  end

  context "With a grammar for first and last names broken up differently" do

    def grammar
      <<-HERE.unindent
        module Skylab::Basic::TestSupport
          grammar PersonName_03
            rule person_name
              t_1_first:name
              n_2_last:(
                ' '+
                name
              )?
              <Node>
            end
            rule name
              [a-z]+
              <Node>
            end
          end
        end
      HERE
    end

    it "(the treetop grammar parses inputs like normal)" do

      o = parser
      _ = o.parse 'mary'
      _ or fail

      _ = o.parse 'joe bob'
      _ or fail

      _ = o.parse 'joe bob briggs'
      expect( _ ).to be_nil
    end

    context "because the grammar is broken up more optimally" do

      context 'the sexp for the string "mary"' do

        def input
          'mary'
        end

        def expected

          [ :person_name, [ :first, "mary" ], [ :last, EMPTY_S_ ] ]
        end

        specify do
          should eql expected
        end
      end

      context 'the sexp for the string "joe bob" now has a thing that is accessible' do

        def input
          'joe bob'
        end

        def expected

          [ :person_name, [ :first, "joe" ], [ :last, " ", "bob" ] ]
        end

        specify do
          should eql expected
        end
      end
    end
  end

  context "When you want custom sexp classes" do

    module ::Skylab::Basic::TestSupport

      class MySexp < Home_::Sexp
        Home_::Sexp::Registrar[ self ]
      end

      class Bread < MySexp

        register :top_slice
        register :bottom_slice

        def calories
          "#{ unparse } has 100 calories"
        end
      end

      module Sandwich

        class MyNode < Home_.lib_.treetop::Runtime::SyntaxNode

          Home_::Sexp::Auto.enhance( self ).with_sexp_auto_class MySexp

        end
      end
    end

    def grammar
      <<-HERE.unindent
        module Skylab::Basic::TestSupport
          grammar Sandwich
            rule sandwich
              t_1_top_slice:bread
              ' '
              n_2_items:items
              ' '
              t_3_bottom_slice:bread
              <MyNode>
            end
            rule bread
              'rye' / 'white' / '7 grain'
            end
            rule items
              t_1_item:item
              n_2_more_items:( ' ' n_1_item:item )*
              <MyNode>
            end
            rule item
              'lettuce' / 'tomato'
              <MyNode>
            end
          end
        end
      HERE
    end

    context "(this tree is ANNOYING)" do

      def input
        'rye lettuce tomato rye'
      end

      def expected
        [ :sandwich,
          [:top_slice, "rye"],
          [:items, [:item, "lettuce"], [:more_items, " tomato"]],
          [:bottom_slice, "rye"] ]
      end

      it 'works' do

        _raw_tree = parse_result

        _s = _raw_tree.sexp

        expect( _s ).to eql expected
      end
    end

    context "you register them as above and everything just works magically" do

      def input
        '7 grain lettuce tomato 7 grain'
      end

      it "a sexp node with whose label you registered a custom class, #{
          }e.g. Bread" do

        _raw_tree = parse_result

        _sexp = _raw_tree.sexp

        _ts = _sexp.child :top_slice
        expect( _ts.class ).to eql Home_::TestSupport::Bread
      end

      context 'calling the custom method ("calories") on your custom sexp class' do

        specify do
          should eql '7 grain has 100 calories'
        end

        def subject

          sexp.child( :top_slice ).calories
        end
      end
    end
  end

  def subject
    sexp
  end

  let :sexp do
    parse_result.sexp
  end

  let :parse_result do
    parser.parse input
  end

  let :parser do
    parser_class.new
  end

  cache_h = {}  # only build each grammar for each string once

  let :parser_class do

    cache_h.fetch grammar do | s |

      g = Home_.lib_.treetop.load_from_string s
      cache_h[ s ] = g
      g
    end
  end

  def _Treetop
    Home_.lib_.treetop
  end
end

# ->

end
