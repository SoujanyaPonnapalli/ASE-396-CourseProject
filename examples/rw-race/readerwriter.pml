byte value = 0;

init {
  printf("Initializing processes");
}

active proctype ReaderWriterA() {
  atomic {
    if
    :: ( value == 0 ) ->
      value = value + 1;
    fi;
  }
}

active proctype ReaderWriterB() {
  atomic {
    if
    :: (value == 0) ->
      value = value + 1;
    fi;
  }
}

ltl p1 { [] (value == 0 || value == 1) }

