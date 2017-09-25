# README

because we're entering into generated grammar territory, things get a bit
out of our control in terms of what files contain and what they can be
named. so:

  - grammar-.rl: the ragel file where we write our grammar

  - grammar-.rb: the file generated by feeding the above file into ragel.
      (we don't love versioning this file but we want the host sidesystem
      to work out of the box without a dependency on ragel.)

  - grammar-in-c.rl: this is how we first developed the implementation
      of our grammar in ragel. we started with a C-hosted grammar rather
      than a ruby-hosted grammar so we could stay closer to the examples
      in the guide as we came to an understanding of how things worked like
      string capturing and error reporting.
      for now we're keeping this file around A) for reference and B) because
      it still works and is a standalone proof of concept.
      (we do not version the generated C file.)

  - parse-tree-via-string.rb: the motivation behind this file's existence is
      primarily to keep excess noise out of the first file in this list,
      because all ruby code there is duplicated into the second file, and
      we prefer not to have our code duplicated in versioned files because
      it can create noise and misdirection when searching for the origin
      of code features. also this file compartmentalizes things for us a bit..