require_relative '../../test-support'

module Skylab::Parse::TestSupport

  module Fz_SO_G___  # :+#throwaway-module for constants generated during tests

    # <-

  TS_.describe "[pa] functions - serial optionals" do

    it "there is a highlevel shorthand inline convenience macro" do

      args = [ '30', 'other' ]

      age, sex, loc =  Parse_.parse_serial_optionals args,
        -> a { /\A\d+\z/ =~ a },
        -> s { /\A[mf]\z/i =~ s },
        -> l { /./ =~ l }

      age.should eql '30'
      sex.should eql nil
      loc.should eql 'other'
    end

    context "curried usage" do

      before :all do
        P = Parse_.function( :serial_optionals ).new_with(
          :matcher_functions,
            -> age do
              /\A\d+\z/ =~ age
            end,
            -> sex do
              /\A(?:m(?:ale)?|f(?:emale)?|o(?:ther)?)\z/i =~ sex
            end,
            -> location do
              /\A[A-Z]/ =~ location   # must start with capital
            end ).to_parse_array_fully_proc
      end

      it "full normal case (works to match each of the three terms)." do
        P[ [ '30', 'male', "Mom's basement" ] ].should eql [ '30', 'male', "Mom's basement" ]
      end

      it "one valid input token will match any first matching formal symbol found" do
        P[ [ '30' ] ].should eql [ '30', nil, nil ]
      end

      it "successful result is always array as long as number of formal symbols" do
        P[ [ "Mom's basement" ] ].should eql [ nil, nil, "Mom's basement" ]
      end

      it "ergo an earlier matching formal symbol will always win over a later one" do
        P[ [ 'M' ] ].should eql [ nil, 'M', nil ]
      end

      it "because we have that 'fully' suffix, we raise argument errors" do
        argv = [ '30', 'm', "Mom's", "Mom's again" ]
        -> do
          P[ argv ]
        end.should raise_error( ArgumentError,
                     ::Regexp.new( "\\Aunrecognized\\ argument\\ 'Mom's" ) )
      end
    end

    it "you can provide arbitrary procs to implement your parse functions" do
      feet_rx = /\A\d+\z/
      inch_rx = /\A\d+(?:\.\d+)?\z/

      p = subject_parse_module_.new_with(
        :functions,
        :proc, -> st do
          if feet_rx =~ st.current_token_object.value_x
            tok = st.current_token_object
            st.advance_one
            Parse_::Output_Node_.new tok.value_x.to_i
          end
        end,
        :proc, -> st do
          if inch_rx =~ st.current_token_object.value_x
            tok = st.current_token_object
            st.advance_one
            Parse_::Output_Node_.new tok.value_x.to_f
          end
        end ).to_parse_array_fully_proc

      p[ [ "8"   ] ].should eql [ 8,  nil  ]
      p[ [ "8.1" ] ].should eql [ nil, 8.1 ]
      p[ [ "8", "9" ] ].should eql [ 8, 9.0 ]
      -> do
        p[ [ "8.1", "8.2" ] ]
      end.should raise_error( ArgumentError,
                   ::Regexp.new( "\\Aunrecognized\\ argument" ) )
    end

    def subject_parse_module_
      Parse_.function :serial_optionals
    end
  end
  # <-
  end
end
