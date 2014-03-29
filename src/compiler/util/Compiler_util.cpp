#include <common.hpp>

static int memory_leaks = 0;

void *safe_malloc(size_t size)
{
	void *ret = malloc(size);
	if (!ret) {
		fprintf(stderr, "ERROR!!:cannot allocate memory\n");
		exit(EXIT_FAILURE);
	}
	memset(ret, 0, size);
#ifdef DEBUG_MODE
	memory_leaks += size;
#endif
	return ret;
}

void safe_free(void *ptr, size_t size)
{
	if (ptr) {
		free(ptr);
		ptr = NULL;
#ifdef DEBUG_MODE
		memory_leaks -= size;
#else
		(void)size;
#endif
	}
}

int leaks(void)
{
	return memory_leaks;
}

void *safe_realloc(void *ptr, size_t size)
{
	void *new_ptr = realloc(ptr, size);
	assert(new_ptr && "cannot allocate memory");
	return new_ptr;
}
