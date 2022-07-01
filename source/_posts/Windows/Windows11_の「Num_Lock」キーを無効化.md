---
title: Windows11 の「Num Lock」キーを無効化
date: 2022/05/20 17:02:05
tags:
  - windows
categories:
  - Windows
toc: true
#sidebar: none
---

## 課題
ネットワークエンジニアはIPアドレスの入力するなどにテンキーを重宝します。しかし、タイピングするときに間違えて<kbd>Num Lock</kbd>キーを押してしまったら、次に数字を打ちたいのにカーソルが操作されてしまい、若干苛立たしくなるのではないでしょうか？生産性にはともかく、心身の健康にも悪影響を及ぼします。


ところで、今回は、<kbd>Num Lock</kbd>キーを半永久的に無効化する方法をご紹介致したいと思います。
>【永久的】：物理的にキーボードから「Num Lock」キーを取り外し


![chrome_1505x521_220701.png](/resources/1c11b9c1ed07489dae49c0e7d016a5cd.png)


## 解決方法
1. <kbd>Win</kbd>+<kbd>R</kbd>を同時に押して、`regedit`　と入力し、「レジストリ エディター」を開きます。　
![explorer_456x272_220701.png](/resources/42353ad6d2a34de89a552598c2093117.png)

2. アドレスバーに`コンピューター\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout`と入力します。
![regedit_1155x509_220701.png](/resources/d1da1be4dfc44d2f946d714940015859.png)


3. 新しいバイナリエディタ`Scancode Map`
![regedit_1065x423_220701.png](/resources/4f001eb6e94e4d57aa5ab4a1c3e6663d.png)


4. ダブルチェックして以下のように編集します。
> 注意：Num Lockロックしているかをご確認ください。
>
![regedit_617x387_220701.png](/resources/b6b505c4d3984ad086836b911f800778.png)


5. 再起動して完了です。
