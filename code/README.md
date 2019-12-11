This folder contains four contents:
- thread-crashing.pml
- Locking Queue
- Nonblocking Queue
- Makefile

## Thread crashing

This file shows how crashes are simulated in the Promela models for the locking
and the non-blocking queues. If the init, enqueue, and the dequeue operations
take a finite number of steps, we use Promela constructs to simulate a crash
after every step in the function. In particular, we use `choose`, a construct
that introduces non-determinism in Promela, to simulate crashes while executing
the data structure's functions.

## Locking Queue

The locking queue (or just queue) uses two locks that restrict concurrent
threads modifying the head and tail of the queue. With two locks, this queue
implementation allows concurrent threads to enqueue and dequeue values.

Queue has the following contents:
- utils.h
- queue.c
- queue.pml
- crashing-queue.pml

## Nonblocking queue

Non-blocking queue uses compare-and-swap atomic instructions to allow concurrent
threads to see updates from other threads and update the queue consistently.

Nonblocking queue has the following contents:
- utils.h
- queue.c
- queue.pml
- crashing-queue.pml

## Makefile
 
This file shows how to compile and run a Promela model. You could run either the
non-blocking queue's model or the locking queue's model using this Makefile.

Execute `$(Makefile SRC=model.pml)` to run a promela code in the file model.pml
