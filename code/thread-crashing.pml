bit crash = 0;
byte step = 1;

active proctype crashingThread () {
  for (step : 1..4) {
    if
    ::  (step == 1) ->
          printf("Executing step-%d\n", step);
    ::  (step == 2) ->
          printf("Executing step-%d\n", step);
    ::  (step == 3) ->
          printf("Executing step-%d\n", step);
    ::  (step == 4) ->
          atomic {
            printf("DONE!");
            endHere:
            break;
          };
    ::  (step >= 1) ->
          atomic {
            select(crash: 0..1);
            printf("Selected crash-%d\n", crash);
            if
            ::  (crash == 1) ->
                printf("Crashing at step-%d\n", step);
                endHere:
                break;
            :: else -> step--;
            fi;
          };
    fi;
  }
}

#define stepLessThanOne (step <= 1)
#define stepLessThanTwo (step <= 2)
#define stepLessThanThree (step <= 3)
#define stepLessThanFour (step <= 4)
#define correctCrashing1 (crash == 1 && step == 1) -> ([] stepLessThanOne)
#define correctCrashing2 (crash == 1 && step == 2) -> ([] stepLessThanTwo)
#define correctCrashing3 (crash == 1 && step == 3) -> ([] stepLessThanThree)
#define correctCrashing4 (crash == 1 && step == 4) -> ([] stepLessThanFour)
ltl correctCrashing { correctCrashing1 && correctCrashing2 && correctCrashing3 && correctCrashing4 }
