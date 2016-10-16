## general numbering scheme (per [#ts-001])

  - 10s      private models
  - 20s      private magnetics
  - 30s      public models
  - 40s      public magnetics
  - 50s      operatoins (via API)
  - 60s      CLI
  - 70s      iCLI
  - 80s      w
  - 90s      i



## numbering scheme under API, CLI; recursively..

..is endpoints (operations) from least to most complex, distributed more
or less evenly at the time of allocation (or using their historical 1-digit
numbers with a zero added, i.e that number times ten).

(the next day we formalize this "subdividing" with [#ts-024].)

if there are ever deep endpoints this holds recursively, which prevents you
from being able to express the relative complexity of two different
endpoints in different branch nodes but meh, there are currently no
deep endpoints.
