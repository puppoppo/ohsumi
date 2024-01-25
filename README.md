ヒト・sp・完全長のタンパクを集める

ヒト：OC行に"Homo"を含む（もし、ヒトに感染するウイルスを入れたい場合は、OH行を参照する。）
完全長：DE行に"Fragment"を含む
sp："FT   SIGNAL"を含む

0.0_sp.plでデータセットを作成
3610個のタンパク質が該当

1.1_outputWithoutUX.plでシグナル配列に"U","X"を含むものを排除する（なさそう）
なかった

2-1.2_sig_eco.plでFT SIGNALのECOを集めて数とその割合を調査

2-2.2_cc_eco.plでCC   -!- SUBCELLULAR LOCATIONのECOを集めて数とその割合を調査


(3.数をみて実データに採用するECO、"U","X"をどうするか決定する。必要に応じてOH行を採用するか考える。)


X.SPのアミノ酸配列と"CC   -!- SUBCELLULAR LOCATION:"を集めて比較

つくりたいグラフ
・長さと局在の相関
・疎水性と局在の相関

