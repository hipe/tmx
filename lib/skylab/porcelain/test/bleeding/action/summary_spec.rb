# encoding: UTF-8
require_relative 'test-support'

module Skylab::Porcelain::TestSupport::Bleeding::Action # #po-008

  describe "[po][bl] action summary (an inheritable action)" do

    extend Action_TestSupport

    incrementing_anchor_module!

    klass :Base do                             # We will re-use this defn. in
      extend Bleeding::Action                  # several constexts below.
    end

    def self.desc *a
      let( :given_desc ) { a }                 # `desc` is just a more readable
    end                                        # version of this..

    let :subject do
      if given_desc
        _Base.desc(* given_desc)               #  .. and we'll run it here.
      end
      _Base.summary_lines
    end


    context "By default the summary is the first few lines of the desc.  With a desc of" do

      context "three lines" do
        desc 'foo', 'bar', 'baz'
        it('the summary is the first two lines'){ should eql(['foo', 'bar']) }
      end

      context "two lines" do
        desc 'foo', 'biz'
        it('the summary is all of the desc'){ should eql(['foo', 'biz']) }
      end

      context "one line" do
        desc 'foo'
        it('the summary is all of the desc') { should eql(['foo']) }
      end

      context "With no desc indicated at all" do
        let( :given_desc ) { nil } # no-op
        it("ain't no summary when it rains") { should eql([]) }
      end
    end



    context "Child classes inherit parent summaries in an intuitive manner" do

      klass :Child, extends: :Base

      def self.child &b
        let( :given_child_block ) { b }
      end

      let :subject do
        if given_desc
          _Base.desc(* given_desc)
        end
        _Child.class_exec(& given_child_block)
        _Child.summary_lines
      end

      context "So, as the summary is by default the above described function" do
        context "and parent has desc" do

          desc 'foo', 'bar'

          context "and child doesn't change its desc" do
            child do
              # no-op (necessary for clarity, sanity)
            end
            it "then it inherits parent desc and hence parent summary" do
              should eql(['foo', 'bar'])
            end
          end

          context "but child has no desc by explicitly erasing it" do
            child do
              desc.clear
            end
            it "then child has no summary" do
              should eql([])
            end
          end

          context "and if child sets its desc" do
            child do
              desc.replace ['bing']
            end
            it "then it inherits the parent summary function hence uses #{
              }child desc" do
              should eql(['bing'])
            end
          end
        end
      end
    end


    context "The RAW POWER of this is UNLEASHED when you have inherited #{
      }useful functions" do

      klass :Child, extends: :Base do
        desc "ok go"
        summary { ["#{aliases.first}<-->#{desc.last.upcase.gsub('á', 'Á')}"] }
      end

      klass :SubChild1, extends: :Child do
        desc "pootenany", "whootenany"
      end

      klass :SubChild2, extends: :Child do
        desc "say yes to mamá"
      end

      it "it's almost like class-based inheritance!!!" do
        _SubChild1.summary_lines.should eql(['sub-child1<-->WHOOTENANY'])
        _SubChild2.summary_lines.should eql(['sub-child2<-->SAY YES TO MAMÁ'])
      end
    end
  end
end
