module Skylab::TestSupport

  module Regret::API  # [#sl-123] exempt:

  class Actions::DocTest                   # these breaks ..

    module Templos__::Quickie::Context__       # reflect design ..

      module Beforer_                          # choices.

        # here is how the doc-test semantic structures of COMMENT_BLOCK,
        # SNIPPET and PREDICATE line-up with the Quickie structures of
        # CONTEXT, BEFORE_BLOCK, EXAMPLE and PREDICATE:
        #
        # any COMMENT_BLOCK is always isomorphic one-to-one to one CONTEXT.
        #
        # assume that this comment block has multiple SNIPPETs.
        #
        # in any given comment block that has more than one snippet, all code
        # lines in the first snippet before any first PREDICATE in that first
        # snippet will constitue the BEFORE_BLOCK. any remaining code lines
        # of that first snippet (from the first predicate forward) constitue
        # the first EXAMPLE. each next snippet constitues each next example.
        #
        # a corollary of above is that any comment block with more than one
        # snippet will be transformed into a context with a before block
        # and one or more examples.

        def self.build_parts blk, y
          part_a = [ ]
          snips = RegretLib_::Stream[ blk.snippet_a ]
          bef, ex = first_snip snips.gets, y
          bef and part_a << bef
          ex and part_a << ex
          while snip = snips.gets
            part_a << Context__::Part_.build_example( snip, y )
          end
          part_a
        end

        class << self
        private
          def first_snip snip, y
            before_a = example_a = nil
            preds = Templos__::Predicates.new -> line do
              ( example_a ||= [ ] ) << line
              nil
            end, -> line do
              ( before_a ||= [ ] ) << line
              nil
            end
            lines = RegretLib_::Stream[ snip.line_a ]
            while line = lines.gets
              preds.add( line ) and break
            end
            while line = lines.gets
              preds << line
            end
            if before_a
              before_a.pop while
                before_a.length.nonzero? && before_a.last.length.zero?
            end
            if before_a && before_a.length
              bef = Context__::Part_::Before_.new( y ) do |b|
                b.local_lines = before_a
              end
            end
            if example_a
              ex = Context__::Part_::Example_.new( y ) do |e|
                e.quoted_description_string =
                  API_::Support::Templo_.descify snip.last_other
                e.local_lines = example_a
              end
            end
            [ bef, ex ]
          end
        end
      end
    end
  end
  end
end
