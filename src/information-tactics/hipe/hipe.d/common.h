#ifndef HIPE_COMMON_H
#define HIPE_COMMON_H

#define FAILED 0
#define OKAY 1

typedef struct hipe_runner hipe_runner;

struct hipe_runner {
  bool (*run)(hipe_runner *);
};

#endif
