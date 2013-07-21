# working draft of "rules of order" for declaring things

## In summary, when defining a class (and module where applicable):

1. the dsl section: the extension clauses, with any dsl calls
2. include modules in alpha order
3. public instance methods in alpha order
4. p-rotected, private instance methods, alpha order but initialize first


## In Detail,

with design goals of:
+   arranging and expressing things in a way that conveys the most
    amount of information with the least amount of effort required to
    decipher it,
+   prefer having modules opened in one place to many places

0.   open your class
0.5. + normally you shouldn't need to include modules just to get scope
       access to them because of <the convention>
     + normally you shouldn't need to forward-declare submodules that
       you will need in the below DSL section because of
       <the lazy loading option>
1.   The DSL section.
     + for each dsl call that you need to make and can make now
       (because presumably of your parent class),
       + in alphabetical order of method name,
         + (if logic dictates a different order, state this in a comment)
       + make the call each one on its own line (wrapping and indenting
       overlow appropriately).
       + between method calls add 0 or 1 blank line to taste.
     + for each module that you want to extend in alphabetical order
       of its name per <the convention>
       + do not cram extensions of multiple modules in to one line.
         + this makes for more readable and meaningful changesets
         + this makes for more readable sequence of events, because
           when you use a multiple-module form of `extend` it actually
           occurs in stack-order not argument order, which might throw
           some ppl off.
     + immediately following the `extend` line (and possibly 1 blank line),
       + for each CONSTANTS that you may need to set that are specially
         recognzied by (only?) the library, in alphabetical order of
         constant name (noting necessary exceptions),
         + set the CONSTANT. see below note about visibility of values.
         + zero or one blank line to taste
       + for each DSL call that you now will make because you have
         extended the extension:
         + per method and then per method's args, follow the above alpha. rules.
       + make any instance methods public that you need to
       + add zero or one blank like after each such line above to taste.
     + Singleton methods - singleton methods.
     + unless this is the last expression of the surrounding block
       (e.g. if it is at the end of the class body), add at least
       least one blank line between the end of this DSL clause and the
       next clause.  Actually why not put a '# --*--' on it.
2.   Include modules (typically of the InstanceMethods variety)
       + for each module that you will include,
       + alphabetical order (following <the convention>) is important here -
         if you need to break alphabetical order indicate so with a
         comment. ancestor chains can make or break code, and when we
         have precise requirements about the order of them, we want it
         to be broken and fixed org-wide in a consistent way. always
         including modules in the same universally consistent order will
         help to encounter such issues in a more consistent way, saving
         time resolving them subsequently.
       + if you want to break alphabetical order to forward-fit your
         ancestor chain accordingly, do so, just indicate so with a comment
         (a test would be better)

3.   Public instance methods in alpha. order.
       + for reasons
4.   Protected instance methods in alpha. order but with `initialize` first.
       + for reasons
~
