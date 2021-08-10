---
title: Main.c
date: 2020/9/30
categories:
  - Algorithm
tags:
  - C
  - Algorithm
  - FE
toc: true
#sidebar: none
---

```c
#include"global.h"

int main (void) {
    int array[10] = { 2, 1, 8, 5, 4, 7, 9, 0, 6, 3 };
    int array_size=sizeof(array) / sizeof(int);

    printf("step %2d:  ",0);
    print_array(array,array_size);

//    selection_sort(array, array_size);
//    bubble_sort(array, array_size);
//    merge_sort(array, 0, 9);
//    insertion_sort(array, array_size);
    shell_sort(array, array_size);
//    quick_sort(array, 0, 9);
//    heap_sort(array, 9);
    print_array(array,10);
    return 0;

//    int list[10] = {0, 4, 9, 10, 13, 17, 25, 36, 37, 40};
//    int x;
//    int answer;
//
//    printf("x?> ");
//    scanf("%d", &x);
//
//    answer = liner_search(list, 10, x);
//    answer = sorted_liner_search(list, 10, x);
//    answer = binary_search(list, 10, x);
//
//    if (answer != -1) {
//        printf("%d\n", answer);
//    }else{
//        printf("not exist\n");
//    }
}
```

