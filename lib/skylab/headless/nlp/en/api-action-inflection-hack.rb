module Skylab::Headless::NLP::EN::API_Action_Inflection_Hack # [#sl-123] exempt

  # This is a weird old (and fun) #experiment that is salvaged from porcelain.
  # Watch for it to cross-fertilize with instances of action inflection
  # happening elsewhere as [#hl-018].

  # See notes at `NounStem` to see how far down the rabbit hole of inflection-
  # hacking goes.

  # Don't be decieved, we don't want self.extended [#sl-111] pattern here,
  # you just extend this module and you get this one knob:


  def inflection
    # Classes or modules that extend this badboy get an `inflection` knob
    # that does stuff..

    @inflection ||= Inflection.new self
  end



  module Dupe                     # (apparently some mess of a dsl for deep-
                                  # duping)

    def self.extended mod # [#sl-111]
      mod.send :include, Dupe::InstanceMethods
    end

    def dupes *a
      @dupes ||= begin
         anc = Dupe::FUN.detect_ancestor_respond_to[ self, :dupes ]
         if anc
           dupes = anc.dupes.dup
         else
           dupes = [ ]
         end
         dupes
      end
      @dupes.concat( a - @dupes )
    end

    attr_writer :dupes


    o = { }

    o[:detect_ancestor_respond_to] = -> klass, method do
      # will need to change if we want to support modules
      klass.ancestors[1..-1].detect { |m| m.respond_to? method }
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

  end



  module Dupe::InstanceMethods

    def dupes *a
      @dupes ||= self.class.dupes.dup
      @dupes.concat(a - @dupes)
    end


    attr_writer :dupes


    def dupe! other
      other.dupes.each do |prop|
        othr = other.send prop

        if othr.respond_to? :dupe!
          send( prop ).dupe! othr
          next
        end

        if ! instance_variable_defined?( "@#{ prop }" ) ||
             instance_variable_get( "@#{ prop }" ).nil?
        then
          # note it's a copy by reference (except ofc. for final values)
          instance_variable_set "@#{ prop }", othr
        end
      end
    end
  end



  class StringAsStem < ::String
    class << self
      alias_method :[], :new
    end
  end



  class VerbStem < StringAsStem

    ends_with_e_rx = /e\z/i

    define_method :progressive do
      @progressive ||= begin
        if ends_with_e_rx =~ self
          "#{ $~.pre_match }ing"
        else
          "#{ self }ing"
        end
      end
    end

    attr_writer :progressive
  end



  class NounStem < StringAsStem

    def singular
      self
    end

    def singular= x
      define_singleton_method( :singular ) { x }
    end

    def plural
      "#{ self }s" # fine for now
    end

    def plural= x
      define_singleton_method( :plural ) { x }
    end
  end



  class Stems # this is the core of the hack
    extend Dupe

    rx = /([a-z])([A-Z])/

    humanize = -> str do
      str.gsub( rx ){ "#{$1} #{$2}" }.downcase
    end
                                  # automagic is not without its price: in
                                  # order to infer a noun stem from your
                                  # action class name, we will start by assuming
                                  # it is in either the second- or third-to-
    define_method :noun do        # last 'name piece.' (assumption [#hl-018])
      @noun ||= begin             # To find the appropriate action constants
        seen = [ ] ; hop = false  # for the noun, we crawl down the entire
        name_pieces.reduce( ::Object ) do |m, x| # const tree and back up again
          m.const_defined?( x, false ) or break
          y = m.const_get x, false # part-way bc of [#sl-035] - if there is a
          seen.push y             # pure box module, (that is, a module whose
          y                       # only purpose is to be a clean namespace
        end                       # to hold only constituent items), then such
        ok = seen.empty?
        ok ||= -> do              # modules usually do *not* have business
          res = seen[-2]          # semantics - that is, they sometimes do *not*
          begin                   # have a meaningful name as far as we're
            o = seen[-3] or break # concerned here.  So if there is such a
            o.respond_to?( :action_box_module ) or break # module, we want to
            o.action_box_module == res or break # `hop` over it, thereby
            hop = true            # not using it as a basis for our
          end while nil           # noun stem, but rather the const above it
          true
        end.call
        if ok
          word = humanize[ name_pieces[ hop ? -3 : -2 ] ]
          if 's' == word[-1]      # #singularize hack
            word = word.sub( /s\z/, '' )
          end
          NounStem[ word ]
        end
      end
    end

    def noun= mixed
      self.dupes |= [:noun] # duplicate this setting down to subclasses
      mixed = NounStem[ mixed ] if ! mixed.respond_to?( :plural )
      @noun = mixed
    end

    define_method :verb do
      @verb ||= VerbStem[ humanize[ name_pieces.last ] ]
    end

  protected

    def initialize klass
      @klass = klass
    end

    attr_reader :klass

    def name_pieces
      @name_pieces ||= klass.to_s.split '::'
    end
  end



  class Inflect
    # for setting how to inflect things
    #

    def noun *a
      if a.length.zero?
        @noun ||= :singular
      else
        send :noun=, *a
      end
    end

    attr_writer :noun
  end



  class Inflected
    # for getting the inflected thing
    #

    attr_reader :inflection

    def noun
      inflection.stems.noun.send inflection.inflect.noun
    end

  protected

    def initialize inflection
      @inflection = inflection
    end
  end



  class Inflection
    extend Dupe

    dupes :stems

    def inflect
      @inflect ||= Inflect.new
    end

    def inflected
      @inflected ||= Inflected.new self
    end

    def stems
      @stems ||= Stems.new @klass
    end

  protected

    def initialize klass
      @klass = klass
      anc = Dupe::FUN.detect_ancestor_respond_to[ klass, :inflection ]
      if anc
        dupe! anc.inflection
      end
    end
  end
end
