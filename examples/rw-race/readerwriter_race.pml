byte value = 0;

init {
  printf("Initializing processes");
}

active proctype ReaderWriterA() {
  if
  :: ( value == 0 ) ->
      value = value + 1;
  fi;
}

active proctype ReaderWriterB() {
  if
  :: (value == 0) ->
    value = value + 1;
  fi;
}

ltl p1 { [] (value == 0 || value == 1) }

