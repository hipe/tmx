require_relative '../test-support'

module Skylab::Brazen::TestSupport

  module CLI_Support_Arguments_Namespace
    # <-
  TS_.describe "[br] CLI support - arguments - parse ARGV (R=required, O=optional" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_support_arguments

    it "loads" do
      subject_
    end

    context "some syntaxes are not meant to be (O R O)" do

      with_class_ do
        class AAPA_ORO
          Ent_[].call self do
            o :property, :foo,
              :required, :property, :bar,
              :property, :baz
          end
          self
        end
      end

      it "they raise a runtime error at either declare or parse time" do

        _s = "optional argument 'baz' must but did not #{
          }occur immediately after optional argument 'foo'"

        _cls = subject_::Syntax_Syntax_Error
        begin
          against_
        rescue _cls => e
        end

        e.message.should eql _s
      end
    end

    context "(R R O O R R)" do

      with_class_ do
        class AAPA_RROORR
          Ent_[].call self do
            o :required, :property, :alpha,
              :required, :property, :beta,
              :property, :gamma,
              :property, :delta,
              :required, :property, :epsilon,
              :required, :property, :zeta
          end
          self
        end
      end

      it "with 0 comes up short" do
        against_
        want_failure_ :missing, :alpha
      end

      it "with 1 comes us short" do
        against_ :A
        want_failure_ :missing, :beta
      end

      it "with 2 comes up short" do
        against_ :A, :B
        want_failure_ :missing, :epsilon
      end

      it "with 3 comes up short" do
        against_ :A, :B, :C
        want_failure_ :missing, :zeta
      end

      it "with 4 comes up just right" do
        against_ :A, :B, :C, :D
        want_success_ :alpha, :A, :beta, :B, :epsilon, :C, :zeta, :D
      end

      it "with 5 comes up just right" do
        against_ :A, :B, :C, :D, :E
        want_success_ :alpha, :A, :beta, :B, :gamma, :C,
          :epsilon, :D, :zeta, :E
      end

      it "with 6 comes up just right" do
        against_ :A, :B, :C, :D, :E, :F
        want_success_ :alpha, :A, :beta, :B, :gamma, :C, :delta, :D,
          :epsilon, :E, :zeta, :F
      end

      it "with 7 comes up long" do
        against_ :A, :B, :C, :D, :E, :F, :G
        want_failure_ :extra, :E
      end
    end

    context "(R O)" do

      with_class_ do
        class AAPA_RO
          Ent_[].call self do
            o :required, :property, :foo,
              :property, :bar
          end
          self
        end
      end

      it "with 0 comes up short" do
        against_
        want_failure_ :missing, :foo
      end

      it "with 1 comes up ok" do
        against_ :A
        want_success_ :foo, :A
      end

      it "with 2 comes up OK" do
        against_ :A, :B
        want_success_ :foo, :A, :bar, :B
      end

      it "with 3 comes up long" do
        against_ :A, :B, :C
        want_failure_ :extra, :C
      end
    end

    context "(O R)" do

      with_class_ do
        class AAPA_OR
          Ent_[].call self do
            o :property, :foo,
              :required, :property, :bar
          end
          self
        end
      end

      it "with 0 comes up short" do
        against_
        want_failure_ :missing, :bar
      end

      it "with 1 comes up OK" do
        against_ :A
        want_success_ :bar, :A
      end

      it "with 2 comes up OK" do
        against_ :A, :B
        want_success_ :foo, :A, :bar, :B
      end

      it "with 3 comes up long (NOTE which argument is considered 'extra')" do
        against_ :A, :B, :C
        want_failure_ :extra, :B
      end
    end

    context "(R)" do

      with_class_ do
        class AAPA_R
          Ent_[].call self do
            o :required, :property, :foo
          end
          self
        end
      end

      it "with 0 comes up short" do
        against_
        want_failure_ :missing, :foo
      end

      it "with 1 comes up just right" do
        against_ :A
        want_success_ :foo, :A
      end

      it "with 2 comes up long" do
        against_ :A, :B
        want_failure_ :extra, :B
      end
    end

    context "(O)" do
      with_class_ do
        class AAPA_O
          Ent_[].call self do
            o :property, :foo
          end
          self
        end
      end

      it "with 0 comes up OK" do
        against_
        want_success_
      end

      it "with 1 comes up just right" do
        against_ :A
        want_success_ :foo, :A
      end

      it "with 2 comes up long" do
        against_ :A, :B
        want_failure_ :extra, :B
      end
    end

    context "()" do
      with_class_ do
        class AAPA_
          Ent_[][ self ]
          self
        end
      end

      it "with 0 ok" do
        against_
        want_success_
      end

      it "with 1 comes up long" do
        against_ :A
        want_failure_ :extra, :A
      end
    end
  end
  # ->
  end
end
