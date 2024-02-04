ヒト・sp・完全長のタンパクを集める

ヒト：OC行に"Homo"を含む（もし、ヒトに感染するウイルスを入れたい場合は、OH行を参照する。）
完全長：DE行に"Fragment"を含む
sp："FT   SIGNAL"を含む

0.0_sp.plでデータセットを作成
3610個のタンパク質が該当

1. 1_outputWithoutUX.plでシグナル配列に"U","X"を含むものを排除する（なさそう）
なかった

2. 2_sig_eco.plでFT SIGNALのECOを集めて数とその割合を調査

3. 3_cc_eco.plでCC   -!- SUBCELLULAR LOCATIONのECOを集めて数とその割合を調査

4. 4_cc_sub.plでCC   -!- SUBCELLULAR LOCATIONの記述情報を集めて整理する

5. 5_create_dataset.plで局在箇所とsignal配列のfastaファイルを用意する

6. 6_analyze.ipynbでグラフ描画
・長さと局在の相関
・疎水性と局在の相関

