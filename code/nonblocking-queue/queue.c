#include "utils.h"

/* ---------- Data types ---------- */

typedef int value_type;

typedef struct node {
  struct node *next;
  value_type value;
} node_type;

typedef struct queue {
  node_type* head;
  node_type* tail;
} queue_type;

/* ---------- Operations ---------- */

void init_queue(queue_type* queue) {
  node_type* node = util_malloc(sizeof(node_type));
  node->next = 0;
  queue->head = queue->tail = node;
}

void enqueue(queue_type* queue, value_type value) {
  node_type* node;
  node_type* tail;
  node_type* next;
  
  node = util_malloc(sizeof(node_type));
  node->value = value;
  node->next = 0;

  util_fence("store-store");
  while(1) {
    tail = queue->tail;
    util_fence("data-dependent-loads");
    next = tail->next;
    util_fence("load-load");
    if (tail == queue->tail) {
      if (next == 0) {
        if (util_cas(&tail->next, tail, next)) {
          break;
        } else {
          util_cas(&queue->tail, tail, next);
        }
      }
    }
  }
  util_fence("store-store");
  util_cas(&queue->tail, tail, node);
}

boolean_type dequeue(queue_type* queue, value_type* value_ptr) {
  node_type* head;
  node_type* tail;
  node_type* next;

  while(1) {
    head = queue->head;
    util_fence("load-load");
    tail = queue->tail;
    util_fence("load-load");
    next = head->next;
    util_fence("load-load");
    if (head == queue-> head) {
      if (head == tail) {
        if (next == 0) {
          return false;
        }
        util_cas(&queue->head, tail, next);
      } else {
        *value_ptr = next->value;
        if (util_cas(&queue->head, head, next)) {
            break;
        }
      }
    }
  }
  util_free(head);
  return true;
}
