module Skylab::Treemap

  class API::Action
                                               # (order matters!)

    extend Treemap::Core::Action::ModuleMethods# gets method definers
                                               # gets normalized name inference

    ACTIONS_ANCHOR_MODULE = -> { API::Actions }  # idem

    include Treemap::Core::Action::InstanceMethods  # idem, stylers

    extend Headless::NLP::EN::API_Action_Inflection_Hack  # for noun inflection
                                               # when reporting actions
    inflection.lexemes.noun = 'treemap'          # idem (might be smell in api)


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
        good, bad = [:&, :-].map { |x| actul.send x, forml } # 1. check for and
        if bad.length.nonzero?                             # short circuit if
          error "unrecognized parameter#{ s bad }: #{      # any bad keys.
            }#{ and_ bad.map{ |k| param k } }"
          break
        end                                                # 2. absorb provided
        good.each { |k| send "#{ k }=", param_h.delete( k ) } # [#020], [#021]
        @error_count.zero? or break                        # with short circuit
        formal.with :default do |name, attr|               # 3. set defaults
          send "#{ name }=", attr[:default] if send( name ).nil?  # (the get
        end                                                # any val/norm)
        a = formal.each.reduce( [ ] ) do |m, (name, attr)|  # 4. check missing
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

  protected

    # (the below solves [#011] - tree grows down) **NOTE** api actions do
    # *not* typically wire themselves to the client -- it is for the (modal)
    # client to decide how the api action should be wired, with knowledge
    # of the event profile of the api action.

    def initialize modal_rc
      Treemap::CLI::Action === modal_rc or fail "sanity - this has #{
        }changed - we construct api actions with a mode client now, #{
        } had: #{ modal_rc.class }"
      init_treemap_sub_client -> { modal_rc }
      @validation_errors = API::Action::Generic_Box.new
      clear_attribute_ivars
      nil
    end

    # parts of the system seem to think they are special

    def error text, *annot
      @error_count += 1
      emit :error, text, *annot
      false
    end

    def info text, *annot  # they think the rules don't apply
      emit :info, text, *annot
      false
    end
    -> do

      norm_h = {
        1 => -> x { x },
        2 => -> a, b { b.merge message: a }
      }

      define_method :build_event do |stream_name, *payload_a|
        payload_x = norm_h.fetch( payload_a.length )[ * payload_a ]
        @event_factory[ self.class, stream_name, payload_x ]
      end
    end.call

    def add_validation_error_for attr_name, *mixed_message
      @error_count += 1
      ( @validation_errors[attr_name] ||= [] ).push mixed_message
      nil
    end

    def clear
      clear_attribute_ivars
      @error_count = 0
      @validation_errors.clear
      nil
    end

    def flush_validation_messages
      @validation_errors.each do |fattr_norm_name, errors|
        phrase_a = errors.reduce( [] ) do |y, (func)| # future-proof the sig
          y << instance_exec(& func )
          y
        end
        errors.clear
        error "#{ param fattr_norm_name } #{ phrase_a.join ' and it ' }"
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
  end

  class API::Action::Generic_Box < MetaHell::Formal::Box # experiment
    public :clear
    def [] k     ; fetch( k ) { } end
    def []= k, v ; add k, v end
  end
end
