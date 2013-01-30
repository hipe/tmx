module Skylab::Treemap

  class API::Action
                                               # (order)

    extend Headless::Action::ModuleMethods     # for normalized name inference

    ACTIONS_ANCHOR_MODULE = -> { API::Actions }  # idem

    include Treemap::Core::Action::InstanceMethods  # idem, stylers

    extend Headless::NLP::EN::API_Action_Inflection_Hack  # for noun inflection
                                               # when reporting actions
    inflection.stems.noun = 'treemap'          # idem


    extend MetaHell::Formal::Attribute::Definer # formal attributes can be used
                                               # for the 95% use case of
                                               # parameter validation

    include Treemap::Adapter::InstanceMethods::API_Action # not necessarily
                                               # every action needs them

    extend PubSub::Emitter                     # this has to come after s.c
                                               # because of `emit`

    attribute_metadata_class do
      def is? mattr                            # exp.
        fetch mattr do end
      end
      def label_string                         # bc. _not_ modality aware!
        fetch :label do                        # future-proofing,
          normalized_name.to_s.gsub '_', ' '   # if metaattr not exist
        end
      end
    end

    counter = ::Hash.new { |h, k| h[k] = 0 }

    define_singleton_method :chain do |new_name, &body|
      num = counter[ new_name ] += 1
      prev = "treemap_original_#{ new_name }_#{ num }"
      alias_method prev, new_name
      define_method new_name do |x|
        y = -> xx { send prev, xx }
        instance_exec x, y, &body
      end
      nil
    end

    meta_attribute :default

    meta_attribute :enum do |attribute_name, attr_metadata|
      chain "#{ attribute_name }=" do |x, y|
        if attr_metadata[:enum].include?( x ) then y[ x ] else
          at_the_time = attr_metadata[:enum].dup # (but still not safe.. (..))
          add_validation_error_for attribute_name, -> do
            "must be #{ or_ at_the_time.map(& method(:pre)) } #{
              }(had #{ val x })"
          end
        end
        x
      end
    end

    meta_attribute :path do |name|
      chain "#{ name }=" do |path, y|
        y[ path ? ::Pathname.new( path ) : path ]
        path
      end
    end

    meta_attribute :regex do |name, attr_metadata|
      chain "#{ name }=" do |x, y|
        if attr_metadata[:regex].first =~ x.to_s
          y[ $~[0] ]
        else
          add_validation_error_for name, -> do
            attr_metadata[:regex].last.gsub '{{value}}', value( x )
          end
        end
        x
      end
    end

    meta_attribute :required

    # -- * --




                                  # mutates param_h (experimental
                                  # future-proofing for possible chaining or
                                  # action aggregtation, etc.) [#021]
    def invoke param_h            # this was the original [#hl-047]
      res = false ; formal = formal_attributes
      begin
        forml, actul = formal.names, param_h.keys
        good, bad = [:&, :-].map { |x| actul.send x, forml } # bad keys
        if bad.length.nonzero?
          error "unrecognized parameter#{ s bad }: #{
            }#{ and_ bad.map{ |k| param k } }"
          break
        end                                                # process provided
        good.each { |k| send "#{ k }=", param_h.delete( k ) } # [#020], [#021]
        @error_count.zero? or break                        # early stop
        formal.with :default do |name, attr|               # defaults
          send "#{ name }=", attr[:default] if send( name ).nil?
        end
        a = formal.each.reduce( [ ] ) do |m, (name, attr)|  # check missing
          m << attr if attr.is? :required and send( name ).nil?
          m
        end
        if a.length.nonzero?
          error "missing required parameter#{ s a } - #{
            }#{ and_ a.map { |o| param o.first } }"
          break
        end
        res = true
      end while nil
      if res
        res = execute
      else
        flush_validation_messages
      end
      res
    end

    attr_writer :stylus # when the action is built and wired it gets this

  protected

    def initialize api_client
      _treemap_sub_client_init nil
      @validation_errors = API::Action::Generic_Box.new
      clear_attribute_ivars
      @api_client = api_client
      nil
    end

    def add_validation_error_for attr_name, *mixed_message
      @error_count += 1
      ( @validation_errors[attr_name] ||= [] ).push mixed_message
      nil
    end

    attr_reader :api_client

    def clear
      clear_attribute_ivars
      @error_count = 0
      @validation_errors.clear
      nil
    end

    def flush_validation_messages
      @validation_errors.each do |name, errors|
        label = formal_attributes.if? name, -> x do
          x.label_string
        end, -> do
          "**#{ name }**"
        end
        phrase_a = errors.reduce( [] ) do |y, (func)| # future-proof the sig
          y << instance_exec(& func )
          y
        end
        errors.clear
        error "#{ param label } #{ phrase_a.join ' and it ' }"
        errors.clear
      end
      @validation_errors.clear
      nil
    end

    alias_method :formal_attribute_definer, :singleton_class

    def formal_attributes
      formal_attribute_definer.attributes
    end

    def clear_attribute_ivars
      formal_attributes.names.each { |k| instance_variable_set "@#{ k }", nil }
      nil
    end

    def payload line              # imagine having this live in or or another
      emit :payload, line         # but not both of the two sides
      nil
    end

    def request_client
      @api_client
    end

    attr_reader :stylus
  end

  class API::Action::Generic_Box < MetaHell::Formal::Box # experiment
    public :clear
    def [] k     ; fetch( k ) { } end
    def []= k, v ; add k, v end
  end
end
