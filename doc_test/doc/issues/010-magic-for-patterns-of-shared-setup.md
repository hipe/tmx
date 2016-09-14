# [title per filename] :[#010]

this behavior phenomenon predates this attempt to desribe it by years..

we almost tried to work "anti-patterns" into the name.

this builds directly from [#024] node theory. specifically we'll be
talking about the "OE" pattern in a series of code runs; which expresses
as a "context".

all tests under this concern and only those tests under this concern will
have a tag whose head is `#coverpoint5-`.




## :#coverpoint5-1 - constants in setup (:A)

(this is all experimental, the main objective of which is to retrofit back
to ancient doctests, while trying to implement their intent with means
that are more contemporary. EDIT)

if a shared setup appears to define a constant (detected through hackery,
we check only the first line of the setup, and it has to match one of
three naive patterns); then it is a match for this setup pattern.

the expression of this setup pattern is EDIT

here's a Dr. Seuss story:

    # (pretend this is "test/3-weeple-deeples/2-shim-dim_speg.kd")

    some code

    # this line becomes the description for the context
    # this line ignored (and any lines after it that aren't the last one)
    # here's the setup:
    #
    #     module MyModule
    #       module MySecondModuleWhichIsInside
    #         class << self
    #           # imagine this is some enhancement you are testing
    #           def bazoink
    #             :_dr_seuss_
    #           end
    #         end
    #       end
    #     end
    #
    # this paragraph will be ignored. (and so on.)
    #
    # here's one test that tests side effects of the above:
    #
    #     MyModule::MySecondModuleWhichIsInside.bazoink  # => :_dr_seuss_

the above produces:

    context "this line becomes the description for the context" do

      before :all do
        module X_wd_sd_MyModule
          module MySecondModuleWhichIsInside
            class << self
              # imagine this is some enhancement you are testing
              def bazoink
                :_dr_seuss_
              end
            end
          end
        end
      end

      it "here's one test that tests side effects of the above" do
        X_wd_sd_MyModule::MySecondModuleWhichIsInside.bazoink.should eql :_dr_seuss_
      end
    end




## rules & implementation (:B)

some "unassertive runs" are shared setup and others are "const definitions".
the former are covered by our older sibling document, and the latter work
like this:

EDIT (see this commit message for notes)



## the actual thing we used to do (and still do) "by hand" (:C)
