/* ----------------------------------------------------------------------------
   Written by Soujanya Ponnapalli, 12/09/2019
   Persistent Queue: Adopting the DRAM queue for Persistent Memory

Assumptions:
1. Some modeling constructs are maintained in PM, while the rest are in DRAM
2. Persistent memory instruction reodering is similar to the reorderings in
relaxed memory models.
3. Thread-level store buffers model the persistent memory controller.
---------------------------------------------------------------------------- */

#define TRUE 1
#define FALSE 0
#define UNDEF 255
#define IF if ::
#define FI :: else fi
#define FOR(i,l,h) i = l ; do :: i < h ->
#define ROF(i,l,h) ; i++ :: i >= h -> break od
#define HEAPSIZE 8
#define INITQUEUESIZE 9
#define ENQUEUESIZE 9
#define DEQUEUESIZE 12
#define RETVALSIZE 2
#define malloc(X) X = cur ; cur++
#define free(X) atomic{ next[X] = UNDEF; value[X] = UNDEF}

/* ----------------------------------------------------------------------------
   Adding crash consistency semantics to the concurrent persistent queue
Technique: Add crashing and recovery code
Locking constructs are volatile and hence are reset across crashes.
Otherwise, all other global variables are on persistent memory
---------------------------------------------------------------------------- */

byte next[HEAPSIZE]; /* model of the heap */
byte value[HEAPSIZE];
byte cur = 0;
byte head = UNDEF; /* the queue structure */
byte tail = UNDEF;
bit headlock = 1;
bit taillock = 1;
/* stores output from dequeue */
byte retval[RETVALSIZE];
byte i = 0 ;

proctype initqueue() {
  bit done[INITQUEUESIZE];
  byte dummy;
  bit crash = 0;
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
    !done[1] -> malloc(dummy); done[1] = TRUE
  }
  :: atomic {
    !done[2] && done[1] -> next[dummy] = UNDEF; done[2] = TRUE
  }
  :: atomic {
    !done[3] && done[1] -> value[dummy] = UNDEF; done[3] = TRUE
  }
  :: atomic {
    !done[4] && done[1] -> head = dummy; done[4] = TRUE
  }
  :: atomic {
    !done[5] && done[1] -> tail = dummy; done[5] = TRUE
  }
  :: atomic {
    !done[6] && done[1] -> headlock = 1; done[6] = TRUE
  }
  :: atomic {
    !done[7] && done[1] -> taillock = 1; done[7] = TRUE
  }
  :: atomic {
    done[1] && done[2] && done[3] && done[4] && done[5] && done[6] && done[7] ->
      break
  }
  od
}

proctype enqueue(byte val) {
  bit done[ENQUEUESIZE];
  bit crash = 0;
  byte node, queuetail;
  do
  :: atomic {
    select(crash: 0..1);
    if
    :: (crash == 1) -> :: atomic {
      // Add recovery code here!
      skip;
    }
    fi
  }
  :: atomic {
    !done[1] -> malloc(node); done[1] = TRUE
  }
  :: atomic {
    !done[2] && done[1] -> value[node] = val; done[2] = TRUE
  }
  :: atomic {
    !done[3] && done[1] -> next[node] = UNDEF; done[3] = TRUE
  }
  :: atomic {
    !done[4] && taillock == 1 -> taillock = 0; done[4] = TRUE
  }
  :: atomic {
    !done[5] && done[4] -> queuetail = tail; done[5] = TRUE
  }
  :: atomic {
    !done[6] && done[2] && done[3] && done[5] -> next[queuetail] = node; done[6] = TRUE
  }
  :: atomic {
    !done[7] && done[1] && done[4] && done[5] -> tail = node; done[7] = TRUE
  }
  :: atomic {
    !done[8] && done[2] && done[3] && done[6] && done[7] -> taillock = 1; done[8] = TRUE;
    break
  }
  od
}

proctype dequeue(byte rv) {
  bit done[DEQUEUESIZE];
  bit crash = 0;
  byte node, new_head, tmp;
  atomic{headlock == 1 -> headlock = 0};
  node = head;
  new_head = next[node];
  if
  :: atomic {
    new_head == UNDEF -> headlock = 1 ;
    retval[rv] = 0
  }
  :: new_head != UNDEF ->
    do
    :: atomic {
      select(crash: 0..1);
      if
      :: (crash == 1) -> :: atomic {
        // Add recovery code here!
        skip;
      }
      fi
    }
   :: atomic {
      !done[7] -> tmp = value[new_head];
      done[7] = TRUE
    }
    :: atomic {
      !done[8] && done[7] -> retval[rv] = tmp;
      done[8] = TRUE
    }
    :: atomic{
      !done[9] -> head = new_head;
      done[9] = TRUE
    }
    :: atomic {
      !done[10] && done[8] && done [9] -> headlock = 1;
      done[10] = TRUE
    }
    :: atomic{
      !done[11] && done[10] -> free(node);
      done[11] = TRUE;
      break
    }
    od
  fi
}

init{
  atomic{
    FOR(i,0,HEAPSIZE)
      next[i] = UNDEF ; value[i] = UNDEF
      ROF(i,0,HEAPSIZE)
  };
  run initqueue();
  timeout -> atomic{run enqueue(4) ; run dequeue(0)} ;
  timeout -> assert(retval[0] == 0 || retval[0] == 4)
}
