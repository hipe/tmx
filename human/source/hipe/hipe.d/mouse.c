#include "mouse.h"

#include <string.h>
#include <stdio.h>



typedef struct {
  unsigned int mask;
  char * name;
} hipe_mouse_event_type;

#define HIPE_MOUSE_RELEASED 001
#define HIPE_MOUSE_PRESSED  002
#define HIPE_MOUSE_CLICKED  004

#define HIPE_MOUSE_EVENT_TYPES_LENGTH 3 /*help*/
static hipe_mouse_event_type hipe_mouse_event_types[] = {
  { HIPE_MOUSE_PRESSED  , "press"   },
  { HIPE_MOUSE_RELEASED , "release" },
  { HIPE_MOUSE_CLICKED  , "click"   }
};

hipe_mouse_event_type *hipe_mouse_event_type_lookup(unsigned int id) {
  int i;
  for (i = 0; i < HIPE_MOUSE_EVENT_TYPES_LENGTH ; i++) {
    if (id == hipe_mouse_event_types[i].mask) {
      return  &hipe_mouse_event_types[i];
    }
  }
  return NULL;
}


typedef struct {
  mmask_t bstate;
  unsigned int button_number;
  unsigned int type;
  unsigned int click_number;
} hipe_mouse_state;

#define HIPE_MOUSE_STATES_LENGTH 20 /* help */
static hipe_mouse_state hipe_mouse_states[] = {
  { BUTTON1_PRESSED          , 1 , HIPE_MOUSE_PRESSED  , 1 },
  { BUTTON1_RELEASED         , 1 , HIPE_MOUSE_RELEASED , 1 },
  { BUTTON1_CLICKED          , 1 , HIPE_MOUSE_CLICKED  , 1 },
  { BUTTON1_DOUBLE_CLICKED   , 1 , HIPE_MOUSE_CLICKED  , 2 },
  { BUTTON1_TRIPLE_CLICKED   , 1 , HIPE_MOUSE_CLICKED  , 3 },
  { BUTTON2_PRESSED          , 2 , HIPE_MOUSE_PRESSED  , 1 },
  { BUTTON2_RELEASED         , 2 , HIPE_MOUSE_RELEASED , 1 },
  { BUTTON2_CLICKED          , 2 , HIPE_MOUSE_CLICKED  , 1 },
  { BUTTON2_DOUBLE_CLICKED   , 2 , HIPE_MOUSE_CLICKED  , 2 },
  { BUTTON2_TRIPLE_CLICKED   , 2 , HIPE_MOUSE_CLICKED  , 3 },
  { BUTTON3_PRESSED          , 3 , HIPE_MOUSE_PRESSED  , 1 },
  { BUTTON3_RELEASED         , 3 , HIPE_MOUSE_RELEASED , 1 },
  { BUTTON3_CLICKED          , 3 , HIPE_MOUSE_CLICKED  , 1 },
  { BUTTON3_DOUBLE_CLICKED   , 3 , HIPE_MOUSE_CLICKED  , 2 },
  { BUTTON3_TRIPLE_CLICKED   , 3 , HIPE_MOUSE_CLICKED  , 3 },
  { BUTTON4_PRESSED          , 4 , HIPE_MOUSE_PRESSED  , 1 },
  { BUTTON4_RELEASED         , 4 , HIPE_MOUSE_RELEASED , 1 },
  { BUTTON4_CLICKED          , 4 , HIPE_MOUSE_CLICKED  , 1 },
  { BUTTON4_DOUBLE_CLICKED   , 4 , HIPE_MOUSE_CLICKED  , 2 },
  { BUTTON4_TRIPLE_CLICKED   , 4 , HIPE_MOUSE_CLICKED  , 3 }
};

typedef struct {
  unsigned int count;
  unsigned int button_number;
  char        *type_string;
  unsigned int click_number;
} hipe_mouse_meta;

hipe_mouse_meta *hipe_mouse_meta_lookup(hipe_mouse_meta *, MEVENT *);



#define HIPE_MOUSE_BUFFER_SIZE 80

char *hipe_mouse_event_describe(MEVENT *e) {
  static char buffer[HIPE_MOUSE_BUFFER_SIZE];
  hipe_mouse_meta m;
  hipe_mouse_meta_lookup(&m, e);
  sprintf(buffer, "(%d) button %d %s (%d arity) at (y: %d, x: %d)",
    m.count, m.button_number, m.type_string, m.click_number, e->y, e->x);
  return buffer;
}

int _hipe_mouse_meta_count = 0;

hipe_mouse_meta *hipe_mouse_meta_lookup(hipe_mouse_meta *m, MEVENT *e) {
  _hipe_mouse_meta_count += 1;
  hipe_mouse_state *found = NULL; int i = -1 ;
  while (++i < HIPE_MOUSE_STATES_LENGTH) {
    if (hipe_mouse_states[i].bstate == (hipe_mouse_states[i].bstate & e->bstate)) {
      found = &hipe_mouse_states[i];
      break;
    }
  }
  if (NULL != found) {
    m->count         = _hipe_mouse_meta_count;
    m->button_number = found->button_number;
    m->click_number  = found->click_number;
    m->type_string   = hipe_mouse_event_type_lookup(found->type)->name;
  } else {
    m = NULL;
  }
  return m;
}
