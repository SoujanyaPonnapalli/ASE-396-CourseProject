bit crash = 0;
byte step = 1;

mtype MAX_STEPS = 4;

active proctype crashingThread () {
  do
  ::  (step < MAX_STEPS) ->
      printf("Executing step-%d\n", step);
      step++;
  ::  (step == MAX_STEPS) ->
    break;
  ::  (step > 1) ->
      atomic {
        select(crash: 0..1);
        if
        ::  (crash == 1) ->
              printf("Crashing at step-%d\n", step);
              break;
        ::  else -> skip;
        fi;
      };
  od;
}

#define stepsBoundaries (step <= MAX_STEPS && step >= 1)
ltl p1 { [] stepsBoundaries }
