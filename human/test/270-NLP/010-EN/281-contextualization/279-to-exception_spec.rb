require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization - `to_exception`" do

    # #C15n-test-family-5 (for [ac])

    TS_[ self ]
    use :memoizer_methods
    use :NLP_EN_contextualization
    use :NLP_EN_contextualization_DSL

    context "(the normalest example)" do

      given do |p|

        p.call :error, :expression do |y|
          y << highlight( 'ding' )
          y << 'dong'
        end

        exception_by do |co, dsl|
          _build_exception co, dsl
        end
      end

      it "message is OK" do
        expect( first_line_ ).to eql  "** ding **"
        expect( second_line_ ).to eql 'dong'
      end

      it "class is something default" do
        exception_class_ == ::RuntimeError || fail
      end
    end

    context "two edges in one test eek" do

      given do |p|

        p.call :info, :expression, :errno_enoent do |y|
          y << highlight( 'ding' )
          y << 'dong'
        end

        exception_by do |co, dsl|
          _build_exception co, dsl
        end
      end

      it "message is OK (such as it is)" do
        first_line_ == "No such file or directory - ** ding **" || fail
        second_line_ == 'dong' || fail
      end

      it "class is something special>" do
        exception_class_ == ::Errno::ENOENT || fail
      end
    end

    def _build_exception co, dsl
      co.given_emission( dsl.channel, & dsl.emission_proc )
      co.to_exception
    end
  end
end
