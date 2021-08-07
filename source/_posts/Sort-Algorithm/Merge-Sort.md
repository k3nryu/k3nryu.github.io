---
title: Merge Sort
date: 2020/9/30
toc: true
---
```c
#ifndef ALGORITHM_MERGE_SORT_H
#define ALGORITHM_MERGE_SORT_H
/* マージソート */
void merge_sort (int array[], int left, int right) {
    int i, j, k, mid,l;
    int work[10];  // 作業用配列
    if (left < right) {
        mid = (left + right)/2; // 真ん中のIndex
        merge_sort(array, left, mid);  // 再帰関数による左を整列
        merge_sort(array, mid+1, right);  // 再帰関数による右を整列

        for (i = mid; i >= left; i--) {// 左半分
            work[i] = array[i];
        }
        for (j = mid+1; j <= right; j++) {
            work[right-(j-(mid+1))] = array[j]; // 右半分を逆順
        }


        i = left; j = right;
        for (k = left; k <= right; k++) {
            if (work[i] < work[j]) {
                array[k] = work[i++];
            }else{
                array[k] = work[j--];
            }
        }

        for (l = 0; l <= right; l++) {
            printf("%d ", work[l]);
            if(l==mid){
                printf("| ");
            }
        }
        printf("\n");
    }
//    printf("step %2d:  ",k);
//    print_array(array,10);
}
#endif //ALGORITHM_MERGE_SORT_H

```
