---
title: Selection Sort
date: 2020/9/30
toc: true
---
```c
#ifndef ALGORITHM_SELECTION_SORT_H
#define ALGORITHM_SELECTION_SORT_H

/* 選択ソート
 * 最小値（または最大値）を見つけて、先頭に移動。2番目に小さい（または大きい）要素を見つけて、2番目に移動。
 * これを 要素数-1番目 まで繰り返して、整列するアルゴリズム。
 * 分かりやすいが、遅い。安定ではない。
 * 比較回数=(n-1)+(n-2)+...+2+1=n(n-1)/2=O(n^2)
 * swap回数=n-1
 */
void selection_sort (int array[], int array_size) {
    int i, j, min_index;

    for (i = 0; i < array_size-1; i++) {
        min_index = i;   // 先頭要素が一番小さいとする
        for (j = i + 1; j < array_size; j++) {
            if (array[j] < array[min_index]) {
                min_index = j;
            }   // 値の比較、最小値の更新
        }
        swap(&array[min_index], &array[i]);   // 最小値と先頭要素を交換
        printf("step %2d:  ",i+1);
        print_array(array,array_size);
    }
}

#endif //ALGORITHM_SELECTION_SORT_H
```
