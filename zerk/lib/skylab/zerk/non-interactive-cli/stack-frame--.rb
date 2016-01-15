module Skylab::Zerk

  class NonInteractiveCLI

    class Stack_Frame__  # code-notes in [#024]

      # for implementing the linked list as described at "why linked list",
      # 3 classes for the 3 kinds of stack frames: root, non-root compound,
      # and formal operation. a complete "selection stack" will always have
      # the form:
      #
      #     ROOT [ NON-ROOT-COMPOUND [..]] FORMAL-OPERATION

      Abstract_Compound_Frame__ = ::Class.new self

      class Root < Abstract_Compound_Frame__

        def initialize cli, acs
          @CLI = cli
          @next_frame_ = nil
          super acs
        end

        def name
          NOTHING_
        end

        def build_PNSA_
          @CLI.build_expressible_program_name_string_array__
        end

        def is_root
          true
        end
      end

      class NonRootCompound < Abstract_Compound_Frame__

        def initialize former_top, qk

          @__association = qk.association
          @next_frame_ = former_top
          super qk.value_x
        end

        def name
          @__association.name
        end
      end

      class Operation < self

        def initialize former_top, fo
          @formal_operation_ = fo
          @next_frame_ = former_top
        end

        def name
          @formal_operation_.name
        end

        attr_reader(
          :formal_operation_,  # 2x
        )

        def wraps_operation
          true
        end
      end

      # --

      class Abstract_Compound_Frame__

        def initialize acs
          @ACS = acs
          @_did_comprehensive_index = false
        end

        # a lookup:
        #   • side-effects an emission IFF not found/ambiguous.
        #   • side-effects the auto-vivification of compound nodes.
        #   • result is:
        #     - false IFF not found
        #     - component association IFF that was resolved
        #     - otherwise the formal operation

        def lookup_straight_then_fuzzy__ token, & oes_p
          rdr = _reader
          k = token.gsub( DASH_, UNDERSCORE_ ).intern
          asc = rdr.read_association k
          if asc
            asc
          else
            fo_p = rdr.read_formal_operation k
            if fo_p
              _build_formal_operation fo_p
            else
              ___lookup_fuzzy token, & oes_p
            end
          end
        end

        def ___lookup_fuzzy token, & oes_p  # result in fo

          # try to match the token fuzzily (but unambiguously) to one of
          # the nodes directly under this frame. if none found, emit a
          # "did you mean (..)"-style emission. result is the found nerp
          # or false.

          o = Begin_fuzzy_retrieve_[ & oes_p ]

          o.stream_builder = streamer_for_lookupable_non_primitives_

          o.name_map = -> qk do
            qk.name.as_slug
          end

          o.set_qualified_knownness_value_and_name token, Name___[]

          no = o.execute
          if no
            no.formal
          else
            no
          end
        end

        def streamer_for_lookupable_non_primitives_

          # we know that with a successful parse we will end up going back
          # over the nodes at this frame to build the option parser. so we
          # do both at once.

          if @_did_comprehensive_index
            self._SANITY
          end

          @_did_comprehensive_index = _do_comprehensive_index

          -> do
            Callback_::Stream.via_nonsparse_array @_cached_nodes_for_fuzzy
          end
        end

        def to_association_stream_for_option_parser___

          # if we went over this once before for a fuzzy lookup then use the
          # cached array. otherwise build it fresh BE CAREFUL!

          if @_did_comprehensive_index
            self._A
          else
            o = @_reader.to_non_operation_node_streamer
            # will #mask
            o.execute.map_reduce_by do |no|
              asc = no.association
              if Association_qualified_for_OP___[ asc ]
                asc
              end
            end
          end
        end

        Association_qualified_for_OP___ = -> asc do

          # we want primitivesques (and when we get to them, entitesques mabye [#021])
          # we do this blacklist-based instead of whitelist-based here,
          # to keep this open at this point

          :compound != asc.model_classifications.category_symbol
        end

        def _do_comprehensive_index

          # the fact that we index lazily is just wishful thinking and is not
          # actually conservative for normal use. see "on avoiding wastefulness"

          stmr = _reader.to_node_streamer

          # will #mask

          for_op = nil
          for_ss = nil
          no = nil

          which2 = {
            primitivesque: -> do
              ( for_op ||= [] ).push no
            end,
            compound: -> do
              ( for_ss ||= [] ).push no
            end
          }

          which = {
            operation: -> do
              ( for_ss ||= [] ).push no
            end,
            association: -> do
              which2.fetch( no.association.model_classifications.category_symbol ).call
            end
          }

          st = stmr.execute
          begin
            no = st.gets
            no or break
            which.fetch( no.category ).call
            redo
          end while nil

          @_cached_nodes_for_fuzzy = for_ss || EMPTY_A_
          @_cached_nodes_for_option_parser = for_op || EMPTY_A_

          ACHIEVED_
        end

        # --

        def _build_formal_operation fo_p

          cur = self
          stack = []
          begin
            stack.push cur
            cur = cur.next_frame_
          end while cur
          stack.reverse!  # so that the root is first element, top is last

          stack.push NIL_  # rely on kind of nasty [#ac-030] to discover name

          fo_p[ stack ]
        end

        Name___ = Lazy_.call do
          Callback_::Name.via_human 'node name'
        end

        def _reader
          @_reader ||= ___build_reader
        end

        alias_method :reader_writer_, :_reader  # track who needs it

        did = false
        define_method :___build_reader do
          did or did = true && Require_ACS_[]
          ACS_::ReaderWriter.for_componentesque @ACS
        end

        attr_reader(
          :ACS,  # [ac] formal op reads it on construction
        )
      end

      # -

        def expressible_program_name_string_array_
          @___pnsa ||= build_PNSA_  # caching may not be useful
        end

        def build_PNSA_

          s_a = @next_frame_.expressible_program_name_string_array_
          s_a.push name.as_slug
          s_a
        end

        attr_reader(
          :next_frame_,
        )

        def wraps_operation
          false
        end

        def is_root
          false
        end
      # -
    end
  end
end
