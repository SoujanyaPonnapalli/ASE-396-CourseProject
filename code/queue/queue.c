#include "utils.h"

/* ---------- Data types ---------- */

typedef int value_type;

typedef struct node {
  struct node* next;
  value_type value;
} node_type;

typedef struct queue {
  node_type* head;
  node_type* tail;
  util_lock_type headlock;
  util_lock_type taillock;
} queue_type;

/* ---------- Operations ---------- */

void init_queue(queue_type* queue) {
  node_type* dummy = util_malloc(sizeof(node_type));
  dummy->next = 0;
  dummy->value = 0;
  queue->head = dummy;
  queue->tail = dummy;
  util_initlock(&queue->headlock);
  util_initlock(&queue->taillock);
}

void enqueue(queue_type* queue, value_type value) {
  node_type* node = util_malloc(sizeof(node_type));
  node->value = value;
  node->next = 0;
  util_lock(&queue->taillock);
  util_fence("store-store");
  queue->tail->next = node;
  queue->tail = node;
  util_unlock(&queue->taillock);
}

boolean_type dequeue(queue_type* queue, value_type* return_value) {
  node_type* node;
  node_type* new_head;
  util_lock(&queue->headlock);
  node = queue->head;
  new_head = node->next;
  if (new_head == 0) {
    util_unlock(&queue->headlock);
    return false;
  }
  util_fence("data-dependent-loads");
  *return_value = new_head->value;
  queue->head = new_head; 
  util_unlock(&queue->headlock);
  util_free(node);
  return true;
}
