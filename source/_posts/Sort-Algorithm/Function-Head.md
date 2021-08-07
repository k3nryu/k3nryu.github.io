---
title: Function Head
date: 2020/9/30
toc: true
---
```c
#ifndef ALGORITHM_FUNCTION_H
#define ALGORITHM_FUNCTION_H
/* 値を交換する関数 */
void swap (int *x, int *y) {
    int temp;    // 値を一時保存する変数

    temp = *x;
    *x = *y;
    *y = temp;
}
/*一次配列を出力する関数*/
void print_array(int array[], int array_size){
    int i;
    for (i = 0; i < array_size; i++) {
        printf("%d ", array[i]);
    }
    printf("\n");
}

#endif //ALGORITHM_FUNCTION_H

```
