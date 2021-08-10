---
title: Binary Search
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
#ifndef ALGORITHM_BINARY_SEARCH_METHOD_H
#define ALGORITHM_BINARY_SEARCH_METHOD_H
/* 二分探索 */
int binary_search (int list[], int list_size, int x) {
    int left, right, mid;
    left = 0;
    right = list_size - 1;

    while (left <= right) {
        mid = (left + right)/2;
        if (list[mid] == x) { return mid; }
        else if (list[mid] < x) { left = mid + 1; }
        else                    { right = mid - 1; }
    }
    return -1;
}
#endif //ALGORITHM_BINARY_SEARCH_METHOD_H

```
