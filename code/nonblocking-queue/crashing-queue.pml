#define TRUE 1
#define FALSE 0
#define UNDEF 255

#define IF if ::
#define FI :: else fi

#define FOR(i, l, h) i = 1; do :: i < h ->
#define ROF(i, l, h) ; i++ :: i >= h -> break od

#define INITQUEUESIZE 5
#define ENQUEUESIZE 9
#define DEQUEUESIZE 5
#define RETVALSIZE 2

#define HEAPSIZE 8
#define malloc(X) X = cur; cur++
#define free(X) atomic{ next[X] = UNDEF; value[X] = UNDEF}

/* ---------- Global variables ---------- */

byte heap_initializer;
byte next[HEAPSIZE];
byte value[HEAPSIZE];
byte cur = 0;
byte head = UNDEF;
byte tail = UNDEF;
byte retval[RETVALSIZE];

proctype init_queue() {
  printf("Executing init_queue");
  bit done[INITQUEUESIZE];
  byte dummy;
  bit crash;
  do
  :: atomic {
    !done[1] -> malloc(dummy);
    done[1] = TRUE
  }
  :: atomic {
    !done[2] && done[1] -> next[dummy] = UNDEF;
    done[2] = TRUE
  }
  :: atomic {
    !done[3] && done[2] -> head = dummy;
    done[3] = TRUE
  }
  :: atomic {
    !done[4] && done[2] -> tail = dummy;
    done[4] = TRUE
  }
  :: atomic {
    done[1] && done[2] && done[3] && done[4] -> break
  }
  od
}

proctype enqueue(byte enq_value) {
  byte node;
  byte enq_tail;
  byte enq_next;
  bit done[ENQUEUESIZE];
  bit crash = 0;

  atomic {
    malloc(node);
    value[node] = enq_value;
    next[node] = UNDEF;
  }
  do
  :: atomic {
    select(crash: 0..1);
    if
    :: (crash == 1) -> :: atomic {
      // Add recovery code here!
      skip;
    }
    fi;
  }
  :: atomic {
    !done[1] -> enq_tail = tail;
    done[1] = TRUE;
  }
  :: atomic {
    !done[2] & done[1] -> enq_next = next[enq_tail];
    done[2] = TRUE;
  }
  :: !done[3] && done[2] && done[1] -> {
    IF (enq_tail == tail)
      if
      :: (enq_next == UNDEF)
        atomic {
          IF (next[enq_tail] == enq_next)
            next[enq_tail] = node;
            done[3] = TRUE
          FI 
        }
      :: else ->
        atomic {
          IF (tail == enq_tail)
            tail = enq_next
          FI
        }
      fi
    FI
  }
  :: done[3] -> atomic {
    IF (tail == enq_tail)
      tail = node;
      break;
    FI
  }
  od
}

proctype dequeue(byte rv) {
  byte dq_head;
  byte dq_tail;
  byte dq_next;
  bit done[DEQUEUESIZE];
  retval[rv] = 0;
  bit crash = 0;

  do
  :: atomic {
    select(crash: 0..1);
    if
    :: (crash == 1) -> :: atomic {
      // Add recovery time
      skip;
    }
    fi;
  }
  :: !done[1] -> atomic {
    dq_head = head;
    done[1] = TRUE;
  }
  :: !done[2] && done[1] -> atomic {
    dq_tail = tail;
    done[2] = TRUE;
  }
  :: !done[3] && done[2] -> atomic {
    dq_next = next[dq_head];
    done[3] = TRUE;
  }
  :: !done[4] && done[3] ->
    IF (dq_head == head)
      if
      :: dq_head == dq_tail -> {
        if
        :: (dq_next == UNDEF) -> {
          break;
        }
        :: else -> atomic {
          IF (head == dq_head)
            head = dq_next;
          FI
        }
        fi
      }
      :: else -> {
        retval[rv] = value[dq_next];
        atomic {
          IF (head == dq_head)
            head = dq_next;
            break;
          FI
        }
      }
      fi
    FI
  od
}

init {
  atomic {
    FOR(heap_initializer, 0, HEAPSIZE)
      next[heap_initializer] = UNDEF;
      value[heap_initializer] = UNDEF;
    ROF(heap_initializer, 0, HEAPSIZE)
  };
  run init_queue();
  timeout -> atomic { run enqueue(4); run dequeue(0); };
  timeout -> assert(retval[0] == 0 || retval[0] == 4)
}
