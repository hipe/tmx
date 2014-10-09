module Skylab::Headless

  class CLI::Option::Enumerator < ::Enumerator  # here b.c of [#mh-035]

    # an adaptive layer around an optionparser for iterating over its options.
    # Iterate over a collection of option-ishes, be they from a stdlib o.p
    # or somewhere else; given either another iterator of arbitrary objects
    # that might be switches, or an o.p-ish.
    #
    # yields each of the strange switches of the option-parser-ish
    # it gets. The sole argument to the constructor
    # must either respond_to `each` and yield successive switch-ish'es
    # or quack like an ::OptionParser in that it respond to
    # `visit` and work like stdlib o.p does w/ regards to a stack
    # that responds to `each_option`.
    #
    # This is useful because it's far too hacky to do the below thing
    # to a stdlib o.p in more than one place, in the universe.

    attr_writer :filter  # this is a pass-filter, like ::Array#map

  private

    -> do

      default_criteria = nil

      define_method :initialize do |x|
        super(& method( :visit ) )
        @criteria ||= default_criteria

        inner = if x.respond_to? :each then x else
          ::Enumerator.new do |y|
            x.send :visit, :each_option do |sw|
              y << sw
            end
            nil
          end
        end

        outer = ::Enumerator.new do |y|
          inner.each do |sw|
            if @criteria[ sw ]  # NOTE you run critera against the strange
              y << @filter[ sw ]  # and then pass the strange to the filter
            end
          end
          nil
        end

        @visit ||= -> y { outer.each(& y.method( :yield ) ) }

        @filter ||= -> o { o }  # this is a pass filter (like `map`)!
      end

      short_long = nil

      default_criteria = -> sw do
        ok = ! short_long.detect { |m| ! sw.respond_to? m }
        ok && short_long.detect { |m| x = sw.send( m ) and x.length.nonzero? }
      end
        # our out-of-the-box criteria for what we mean by "switch" is:
        # it is a nerk that responds to *both* `short` and `long`,
        # and one or more of them is a true-ish of nonzero length.
        # ( There exist in our universe hacks that produce o.p's that have
        # switches that don't meet this criteria!, sometimes by accident
        # [#snag-030] )

      short_long = [ :short, :long ].freeze  # ocd

    end.call

    def visit y
      @visit[ y ]
    end
  end
end
