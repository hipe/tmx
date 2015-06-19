module Skylab::Plugin

  class Strategies  # see [#007]

    class << self

      alias_method :__orig_new, :new

      def new * sym_a

        ::Class.new self do

          class << self

            alias_method :new, :__orig_new
          end

          sym_a.each do | sym |
            define_method sym do
              @_dependency_objects.fetch @_service_providers[ sym ]
            end
          end

          const_set :SLOTS, ::Struct.new( * sym_a )
          self
        end
      end
    end  # >>

    def initialize
      @_dependency_objects = []
      @_initial_assignments = []
      @_service_providers = self.class::SLOTS.new
    end

    def initialize_dup _  # see #note-A.tactical-uptake

      new_dependency_objects = []
      new_initial_assignments = []
      new_service_providers = self.class::SLOTS.new

      seen_h = {}

      @_initial_assignments.each do | frozen_pair |

        d, sym_a = frozen_pair

        seen_h.fetch d do

          seen_h[ d ] = true

          new_dependency_objects[ d ] = @_dependency_objects.fetch( d ).dup
            # (yes it is possible that the above will create holes:
            #  if the client added "initial" assigments after volatile ones)

          NIL_
        end

        sym_a.each do | sym |
          new_service_providers[ sym ] = d
        end

        new_initial_assignments.push frozen_pair
      end

      @_dependency_objects = new_dependency_objects
      @_initial_assignments = new_initial_assignments
      @_service_providers = new_service_providers
      NIL_
    end

    def add_initial_assignment * sym_a, dependency  # see #note-A

      d = _touch_index_of_cached_dependency dependency

      @_initial_assignments.push [ d, sym_a.freeze ].freeze

      sym_a.each do | sym |
        @_service_providers[ sym ] = d
      end
      NIL_
    end

    def replace sym, dep_

      # replace whatever dependency is currently in the argument role with
      # the argument dependency. the replaced dependency is the result of
      # this call. the argument dependency is added to the cache of
      # dependencies IFF it is not already there. but NOTE that the replaced
      # dependency is as yet never removed from the cache; but this may change

      d_ = _touch_index_of_cached_dependency dep_
      d = @_service_providers[ sym ]
      @_service_providers[ sym ] = d_
      @_dependency_objects.fetch d
    end

    def replace_by sym, & map_p

      # whatever dependency is currently in the role is yielded to the block.
      # the result of this block will be used as a replacement dependency.
      # our result is always nil. (:[#bs-010.B] look at that chain!)
      # same NOTE as previous method.

      _old_d = @_service_providers[ sym ]

      _old_dep = @_dependency_objects.fetch _old_d

      _new_dep = map_p[ _old_dep ]

      _new_d = _touch_index_of_cached_dependency _new_dep

      @_service_providers[ sym ] = _new_d

      NIL_
    end

    def _touch_index_of_cached_dependency dep

      oid = dep.object_id

      d = @_dependency_objects.index do | dep_ |
        oid == dep_.object_id
      end

      if ! d
        d = @_dependency_objects.length
        @_dependency_objects[ d ] = dep
      end

      d
    end
  end
end
