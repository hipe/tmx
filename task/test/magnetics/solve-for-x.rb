module Skylab::Task::TestSupport

  module Magnetics::Solve_For_X

    def self.[] tcc
      tcc.include self
    end

    # -

      # -- setup

      def given_ * sym_a
        @given_sym_a = sym_a
      end

      def given_array_ sym_a
        @given_sym_a = sym_a
      end

      def target_ sym
        @target_sym = sym
      end

      def customize_by_ & p
        @customize_by = p
      end

      attr_reader :customize_by

      # -- assertion

      def expect_stack_ * const_a

        _o = _begin_session
        ok, const_a_ = _o.execute
        ok || fail

        if do_debug
          debug_IO.puts const_a_.inspect
        end

        last = const_a.length - 1
        last_ = const_a.length - 1
        d = -1
        begin
          if d < last
            if d < last_
              d += 1
              if const_a_.fetch(d) == const_a.fetch(d)
                redo
              else
                fail __say( d, const_a_, const_a )
              end
            else
              fail __say_result_path_is_too_short( const_a_, last + 1 )
            end
          elsif last_ == last
            break
          else
            fail __say_result_path_is_too_long( const_a_, last + 1 )
          end
        end until broken
        NIL
      end

      def expect_failure_structure__

        o = _begin_session do |o_|
          o_.do_trace = true
        end
        ok, x = o.execute
        ok && fail
        x
      end

      def _begin_session

        _given_sym_a = remove_instance_variable :@given_sym_a
        _target_sym = remove_instance_variable :@target_sym
        _collection = collection_
        o = subject_module_.begin_with _collection, _given_sym_a, _target_sym
        if block_given?
          yield o
        end
        p = customize_by
        if p
          p[ o ]
        end
        o
      end

      # -- support

      def fixture_path_ entry
        ::File.join TS_.dir_path, 'fixture-files', entry
      end

      def collection_via_path_ path

        _big_string = ::File.read path

        _entries = _big_string.split( Home_::NEWLINE_ ).freeze

        _dir = TS_::Magnetics::MockDirectory.via_all_entries_array _entries

        o = magnetics_module_

        _tss = o::TokenStreamStream_via_DirectoryObject[ _dir ]

        o::ItemTicketCollection_via_TokenStreamStream[ _tss ]
      end

      def subject_module_
        Home_::Magnetics::Magnetics::Function_Stack_via_Collection_and_Parameters_and_Target
      end
    # -
  end
end
