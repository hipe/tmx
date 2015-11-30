module Skylab::CodeMolester

  module Config::File::Entity

  METAFIELDS_BASE_ = [

    [ :required, :reflective ],
             # a validation extension might take this to mean
             # that the value must be present and non-nil for the entity
             # to be valid.

    [ :body, :reflective ],
             # a rendering extension might take this to mean that it is
             # to be included as part of the body and not head of the
             # entity (for now it's just used to avoid including `name`
             # in the config file values.. # #todo) (we could just as soon
             # exclude the field that is a natural key. yes that is what
             # we should do. but its existences greases the wheels of
             # parameter inflection for now.

    :list,   # a validation extension might take this to mean that
             # the field value when trueish is enumerable and should be
             # handled as such when validating its value (e.g run the
             # regular expression on every element.)

    [ :ivar, :property ],   # a controller extension might do conversions
             # between `ivar` name and (for lack of a better name name)
             # `field` name - we might use a different name if we ever
             # use it as an ivar - e.g is @tag_a (and :tag_a) vs 'tags'
             # the 'official' name for the field is 'tags' but internally
             # we might prefer to use `tag_a`, with the general rule being
             # that if it is written to a file or displayed to an enduser,
             # use the official name, but if it is a hash key or ivar or
             # variable, opt for the (hungarian notation-like) ivar name.
             # Specify it as a simple symbol itself, e.g `:ivar :tag_a`

    [ :regex, :property ],  # a validation extension might use this to
             # validate the nerks. any more validation that this (e.g
             # number ranges) probably does not belong here, but in an
             # opt-in extension that adds the necessary metafields to
             # your wherever.

    [ :rx_fail_predicate_tmpl, :property ],  # expert mode: if the regex
             # does not match, use this string to generate the error
             # message: it should be a predicate string about the rx match
             # failure. the template (string) can use {{ick}} for which
             # the offending value (string) will be substitued.

    # (leave a trailing comma in the last element (cleaner diffs))
  ].tap { |a| a.freeze.each( & :freeze ) }

  #         ~ import a lot of constants because we are special ~


  class << self

    def enhance target, & p
      flsh = Kernel_.new target
      Shell_.new(
        ->( *a ) do
          flsh.concat_fields a
        end
      ).instance_exec( & p )
      flsh.flush
    end

    define_method :hack_model_name_from_constant, -> do

      str = '::Models::'.freeze

      len = str.length

      -> mod do
        n = mod.name
        a = ( n[ ( n.rindex str ) + len .. -1 ] ).split CONST_SEP_
        a.length.nonzero? or fail "sanity - hack failed (#{ n })"

        self._THE_LAST_BASTION_of_simple_chain

        _a = a.map do | s |
          Callback_::Name.via_const_string s
        end
        Simple_Chain___.new _a
      end
    end.call
  end

  class Simple_Chain___  # #open [#010] go this away for etc

    class << self

      def via_symbol_list name_i_a
        new( name_i_a.map do | sym |
          Home_::Name.via_variegated_symbol sym
        end )
      end
    end  # >>

    def initialize a  # please provide an array of name functions
      @name_a = a ; nil
    end

    def length
      @name_a.length
    end

    def local
      @name_a.last
    end

    def map sym  # for now we protect constituents by doing it like this
      @name_a.map(& sym )
    end

    def anchored_normal
      @anchored_normal ||= @name_a.map( & :as_variegated_symbol ).freeze
    end
  end

  CONST_SEP_ = '::'.freeze

  Event_ = LIB_.old_event_lib  # or a subclass


  #         ~ define the enhancement "contained DSL" ~



  Shell_ = LIB_.plugin::Bundle::Enhance::Shell.new %i( fields )

  class Kernel_

    mutex_h = ::Hash.new do |h, mod|
      h[ mod ] = -> do
        raise "#{ Entity } won't enhance the same module more than once -#{
          } #{ mod }"
      end
      -> { }
    end

    define_method :initialize do |target|
      field_a = nil
      @concat_fields = -> a do
        ( field_a ||= [ ] ).concat a
        nil
      end

      @flush = -> do

        mutex_h[ target ].call

        LIB_.basic::Field.box.via_client_and_proc target, -> do

          meta_fields( * METAFIELDS_BASE_ )

          fields( * field_a ) if field_a

        end
        nil
      end
    end

    def concat_fields a
      @concat_fields[ a ]
    end

    def flush
      @flush.[]
    end
  end

    DASH_ = '-'.freeze
    Entity_ = self
    UNDERSCORE_ = '_'.freeze
  end
end
