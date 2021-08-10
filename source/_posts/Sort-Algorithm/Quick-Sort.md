---
title: Quick Sort
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
#ifndef ALGORITHM_QUICK_SORT_H
#define ALGORITHM_QUICK_SORT_H
/***
* pivotを決め、
* 全データをpivotを境目に振り分け、
* pivotの添え字を返す
***/
int partition (int array[], int left, int right) {
    int i, j, pivot;
    i = left;
    j = right + 1;
    pivot = left;   // 先頭要素をpivotとする

    do {
        do { i++; } while (array[i] < array[pivot]);
        do { j--; } while (array[pivot] < array[j]);
        // pivotより小さいものを左へ、大きいものを右へ
        if (i < j) { swap(&array[i], &array[j]); }
    } while (i < j);

    swap(&array[pivot], &array[j]);   //pivotを更新

    return j;
}

/* クイックソート */
void quick_sort (int array[], int left, int right) {
    int pivot;

    if (left < right) {
        pivot = partition(array, left, right);
        quick_sort(array, left, pivot-1);   // pivotを境に再帰的にクイックソート
        quick_sort(array, pivot+1, right);
    }
    print_array(array,10);

}

#endif //ALGORITHM_QUICK_SORT_H

```
