#!/usr/bin/env ruby -w

# This will probably be a one-off but we're keeping it for posterity for now:
#
#     /path-to-tmx/search_and_replace/bin/tmx-search-and-replace search replace\
#       -f kiss_rdb_test/script/search-and-replace-functions \
#       --filename-pattern '*.py' --filename-pattern '*.dot' \
#       --ruby-regexp '(\bCase\d\d\d\d)' '{{ $1.update_case_number }}'
#       -p kiss_rdb -p kiss_rdb_test -p kiss-rdb-doc --dry-run
#
# This uses our custom search-and-replace utility with a custom replace
# function that looks up case numbers in a hash and substitutes replacement
# case numbers from the values in that hash.
#
# This hash comes from a simple, two-column table in a text file (that we
# call 'ALLO' below (for "allocation")). When this functions file is loaded
# by the utility, it reads the before-and-after case numbers from a file.
#
# You can invoke this file (👇this file☝️) by name to see if the table loads
# without collisions.

module SearchAndReplaceFunctions

  h = {}
  Update_case_number = -> left do

    right = h[left]
    if right.nil?
      $stderr.puts "(nothing yet for #{left.inspect}, skipping.)"
      return left
    end
    repl = right
    $stderr.puts "FOUND ONE: replacing #{left.inspect} with #{repl.inspect}"
    return repl
  end

  Update_case_number.instance_variable_set(:@IDC, h)
end

h = SearchAndReplaceFunctions::Update_case_number.instance_variable_get(:@IDC)

allo_path = '_NOW_/ALLO'  # ..

io = open(allo_path)

seen = {}

while line = io.gets

  line.chop!
  if 0 == line.length
    next
  end

  if "👉 👈" == line
    next
  end

  if '#' == line[0]
    next
  end

  md = /^(\d\d\d\d) (\d\d\d\d)(?: 👈)?$/.match(line)

  if md.nil?
    raise "line faled against regex - #{line.inspect}"
  end

  left_num, right_num = md.captures
  left = "Case#{left_num}"
  right = "Case#{right_num}"

  $stderr.puts "loaded: #{[left, right].inspect}"

  if seen.key? right
    raise "oops, key collision: #{ left.inspect } => >#{ right.inspect }<"
  end
  seen[right] = nil

  if h.key? left
    raise "oops, key collision: >#{ left.inspect }< => #{ right.inspect }"
  end
  h[left] = right
end

# #born as one-off
