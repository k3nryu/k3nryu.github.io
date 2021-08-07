---
title: Bubble Sort
date: 2020/9/30
toc: true
---
```c
#ifndef ALGORITHM_BUBBLE_SORT_H
#define ALGORITHM_BUBBLE_SORT_H
/* バブルソート */
void bubble_sort (int *array, int array_size) {
    int i, j;

//    for (i = 0; i < array_size - 1; i++){
//        for (j = array_size - 1; j >= i + 1; j--){   //　右から左に操作
//            if (array[j] < array[j-1]) {
//                swap(&array[j], &array[j-1]);
//            }
//        }
//        printf("step %2d:  ",i);
//        print_array(array,array_size);
//    }

    for(i=0;i<array_size-1;i++){
        for(j=0;j<array_size-1-i;j++){//左から右に操作
            if(array[j]>array[j+1]){
                swap(&array[j],&array[j+1]);
            }
        }
        printf("step %2d:  ",i+1);
        print_array(array,array_size);
    }
}
#endif //ALGORITHM_BUBBLE_SORT_H

```
