# [title per filename] :[#037]

## intro

some dootilies can footilie




## :#coverpoint5-3 - exceptamundo

here's a Gazpacho story:

    # (pretend this is "test/4-weeple-deeples/5-shim-dim_speg.kd")

    some code

    # ignored because no context
    # comment for your test
    #
    #     jumanji  # => Home_::Your::CustomException: wafiddle diddle..

the above produces:

    it "comment for your test" do
      _rx = ::Regexp.new "\\Awafiddle\\ diddle"

      begin
        jumanji
      rescue Home_::Your::CustomException => e
      end

      e.message.should match _rx
    end
