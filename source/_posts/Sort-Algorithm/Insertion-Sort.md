---
title: Insertion Sort
date: 2020/9/30
toc: true
---
```c
#ifndef ALGORITHM_INSERTION_SORT_H
#define ALGORITHM_INSERTION_SORT_H
/* 挿入ソート */
void insertion_sort (int array[], int array_size) {
    int i, j;

    for (i = 1; i < array_size; i++) {   // 先頭から順にソート
        j = i;
        while ((j > 0) && (array[j-1] > array[j])) {   //整列済みの場合は処理しない
            swap(&array[j-1], &array[j]);   // 整列されていない要素を交換
            j--;
        }
        printf("step %2d:  ",i);
        print_array(array,array_size);
    }

}
//void insertion_sort (int array[], int array_size) {
//    int i, j, k,l;
//    for(j=1;j<array_size;j++){
//        for(i=0;i<j;i++){
//            if(array[j]<array[i]){
//                k=array[j];
//                for(l=j;l>i;l--){
//                    array[l]=array[l-1];
//                }
//                array[i]=k;
//            }
//        }
//        printf("step %2d:  ",j);
//        print_array(array,array_size);
//    }
//}
#endif //ALGORITHM_INSERTION_SORT_H

```
