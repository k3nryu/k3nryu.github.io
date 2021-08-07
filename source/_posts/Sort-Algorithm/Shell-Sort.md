---
title: Shell Sort
date: 2020/9/30
toc: true
---
```c
#ifndef ALGORITHM_SHELL_SORT_H
#define ALGORITHM_SHELL_SORT_H
/* シェルソート */
void shell_sort (int array[], int array_size) {
    int i, j, h;

    for (h = 1; h <= array_size/9; h = 3*h + 1);   // 間隔hを決める
    for ( ; h > 0; h /= 3) {   // hを狭めていく
        /* 以下、挿入ソートとほぼ同じ */
        for (i = h; i < array_size; i++) {
            j = i;
            while ((j > h - 1) && (array[j-h] > array[j])) {
                swap(&array[j-h], &array[j]);
                j -= h;
            }
        }
//        printf("step %2d:  ",h);
//        print_array(array,array_size);
    }
}
#endif //ALGORITHM_SHELL_SORT_H
```

