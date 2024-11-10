#include <stdlib.h>
#include <sys/time.h> /* for gettimeofday system call */
#include "lab.h"


// Struct to hold information for each thread's chunk
typedef struct {
    int *array;
    int start;
    int end;
} ThreadData;

// Forward declarations of helper functions
void *threaded_merge_sort(void *arg);
void merge_sections(int *array, int start1, int end1, int start2, int end2);

// Multi-threaded merge sort function
void mergesort_mt(int *A, int n, int num_threads) {
    int chunk_size = n / num_threads;
    pthread_t threads[num_threads];
    ThreadData thread_data[num_threads];

    // Create threads for each chunk
    for (int i = 0; i < num_threads; i++) {
        thread_data[i].array = A;
        thread_data[i].start = i * chunk_size;
        thread_data[i].end = (i == num_threads - 1) ? n - 1 : thread_data[i].start + chunk_size - 1;

        pthread_create(&threads[i], NULL, threaded_merge_sort, &thread_data[i]);
    }

    // Wait for all threads to finish
    for (int i = 0; i < num_threads; i++) {
        pthread_join(threads[i], NULL);
    }

    // Merge sorted sections two at a time
    int current_chunk_size = chunk_size;
    while (current_chunk_size < n) {
        for (int i = 0; i < n; i += 2 * current_chunk_size) {
            int mid = i + current_chunk_size - 1;
            int end = (i + 2 * current_chunk_size - 1 < n - 1) ? i + 2 * current_chunk_size - 1 : n - 1;
            if (mid < end) {
                merge_sections(A, i, mid, mid + 1, end);
            }
        }
        current_chunk_size *= 2;
    }
}

// Helper function: Sorting function for each thread
void *threaded_merge_sort(void *arg) {
    ThreadData *data = (ThreadData *)arg;
    mergesort_s(data->array, data->start, data->end);  // Updated to use mergesort_s
    return NULL;
}

// Helper function: Merging two sections of the array
void merge_sections(int *array, int start1, int end1, int start2, int end2) {
    int size = end2 - start1 + 1;
    int *temp = (int *)malloc(size * sizeof(int));
    int i = start1, j = start2, k = 0;

    while (i <= end1 && j <= end2) {
        if (array[i] <= array[j]) {
            temp[k++] = array[i++];
        } else {
            temp[k++] = array[j++];
        }
    }
    while (i <= end1) temp[k++] = array[i++];
    while (j <= end2) temp[k++] = array[j++];

    for (i = 0; i < size; i++) {
        array[start1 + i] = temp[i];
    }

    free(temp);
}








/**
 * @brief Standard insertion sort that is faster than merge sort for small array's
 *
 * @param A The array to sort
 * @param p The starting index
 * @param r The ending index
 */
static void insertion_sort(int A[], int p, int r)
{
  int j;

  for (j = p + 1; j <= r; j++)
    {
      int key = A[j];
      int i = j - 1;
      while ((i > p - 1) && (A[i] > key))
        {
	  A[i + 1] = A[i];
	  i--;
        }
      A[i + 1] = key;
    }
}


void mergesort_s(int A[], int p, int r)
{
  if (r - p + 1 <=  INSERTION_SORT_THRESHOLD)
    {
      insertion_sort(A, p, r);
    }
  else
    {
      int q = (p + r) / 2;
      mergesort_s(A, p, q);
      mergesort_s(A, q + 1, r);
      merge_s(A, p, q, r);
    }

}

void merge_s(int A[], int p, int q, int r)
{
  int *B = (int *)malloc(sizeof(int) * (r - p + 1));

  int i = p;
  int j = q + 1;
  int k = 0;
  int l;

  /* as long as both lists have unexamined elements */
  /*  this loop keeps executing. */
  while ((i <= q) && (j <= r))
    {
      if (A[i] < A[j])
        {
	  B[k] = A[i];
	  i++;
        }
      else
        {
	  B[k] = A[j];
	  j++;
        }
      k++;
    }

  /* now only at most one list has unprocessed elements. */
  if (i <= q)
    {
      /* copy remaining elements from the first list */
      for (l = i; l <= q; l++)
        {
	  B[k] = A[l];
	  k++;
        }
    }
  else
    {
      /* copy remaining elements from the second list */
      for (l = j; l <= r; l++)
        {
	  B[k] = A[l];
	  k++;
        }
    }

  /* copy merged output from array B back to array A */
  k = 0;
  for (l = p; l <= r; l++)
    {
      A[l] = B[k];
      k++;
    }

  free(B);
}

double getMilliSeconds()
{
  struct timeval now;
  gettimeofday(&now, (struct timezone *)0);
  return (double)now.tv_sec * 1000.0 + now.tv_usec / 1000.0;
}