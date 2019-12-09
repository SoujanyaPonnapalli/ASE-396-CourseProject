#include <stddef.h>

/* ---------- General ---------- */

enum boolean {
  false = 0,
  true = 1
};

typedef enum boolean boolean_type;

/* ---------- Unsigned types ---------- */

typedef unsigned uint32;
typedef unsigned long long uint64;


/* ---------- Dynamic memory allocation ---------- */

extern void* util_malloc(size_t size);
extern void util_free(void* ptr);

/* ---------- Simple lock ---------- */

typedef unsigned util_lock_type;
extern void util_initlock(util_lock_type* lock);
extern void util_lock(util_lock_type* lock);
extern void util_unlock(util_lock_type* lock);

/* ---------- Fences ---------- */

extern void util_fence(char* fencetype);
