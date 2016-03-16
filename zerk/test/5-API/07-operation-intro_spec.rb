require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - operation intro" do

    TS_[ self ]
    use :API

    context "only write an item - result is the qk (REDUNDANT w/ prev file)" do

      call_by do
        call :left_number, 10  # #test-11
      end

      it "result is qk" do

        qk = root_ACS_result
        qk.association.name_symbol.should eql :left_number
        qk.value_x.should eql 10
      end

      it "emits" do

        _be_this = be_emission_ending_with set_leaf_component_ do |ev|
          black_and_white( ev ).should eql "set left number to 10"
        end

        only_emission.should _be_this
      end
    end

    context "write one item then read another - OK (but eew)" do

      call_by do
        call :left_number, 10, :right_number  # #test-12
      end

      it "emits same" do
        only_emission.should be_emission_ending_with set_leaf_component_
      end

      it "result is qk (unknown)" do
        qk = root_ACS_result
        qk.is_known_known and fail
        qk.association.name_symbol.should eql :right_number
      end
    end

    context "write two items but first fails - second is not written" do

      call_by do
        call :left_number, '--10', :right_number, 11  # #test-10
      end

      it "fails" do
        fails
      end

      it "emits" do
        only_emission.should( be_emission_ending_with( :invalid_number ) do |y|
          y.first.should match %r(\Adidn't .+\(had: "--10"\))
        end )
      end

      it "second not written" do
        root_ACS.instance_variable_defined?( :@right_number ) and fail
      end
    end

    context "write two items but second fails - first stays (NOT ATOMIC)" do

      call_by do
        call :left_number, 10, :right_number, '--11'  # #test-13
      end

      it "fails" do
        fails
      end

      it "emits wrote" do
        first_emission.should be_emission_ending_with set_leaf_component_
      end

      it "emits error" do
        last_emission.should( be_emission_ending_with( :invalid_number ) do |y|
          y.first.should match %r(\Adidn't .+\(had: "--11"\))
        end )
      end

      it "first REMAINS" do
        root_ACS.read_left_number_.should eql 10
      end
    end

    context "write two items then add THEN read a primitivesque - NO" do

      call_by do
        call :left_number, 1, :right_number, 2, :add, :right_number  # #test-04
      end

      it "fails" do
        fails
      end

      it "emits dedicated event" do

        _be_this = be_emission_ending_with past_end_of_phrase_ do |y|
          y.should eql ["arguments continued passed end of phrase - #{
            }unexpected argument: 'right_number'" ]
        end

        last_emission.should _be_this
      end
    end

    # note missing requireds is covered at #here-2

    context "write two items then add" do

      call_by do
        call :left_number, '-2', :right_number, 5, :add  # #test-15
      end

      it "result" do
        root_ACS_result.should eql 3
      end

      # (exemplar of [#ac-032]<->[#028] - needs one stream 3 times..)
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_11_Minimal_Postfix ]
    end
  end
end
