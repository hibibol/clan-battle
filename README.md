汎用的クラバト凸管理Bot

# 出来る事

- クランバトルの際の凸予約管理
- ダメージ管理
- LA時に次回のボスの予約者への通知
- クランメンバーの残凸状況の把握
- 持ち越し状況の把握

# 使い方

入力は数字，ピリオド，スペースは半角と全角両方に対応しています．コマンドを打つ際のアルファベットは半角にのみ対応しています

## 事前準備

まず最初にコマンドを入力する用のチャンネル，予約状況を確認する用のチャンネル(予約確認板)，残凸状況を確認する用のチャンネル(残凸把握板)の3つを用意します．
Botにどのチャンネルを使うか教えてあげます．コマンドを入力する用のチャンネルから以下のコマンドを送信します．チャンネル名を送信する際には必ず#を付けてリンク付きで送信してください．

```
.set 予約確認板 #[予約確認板のチャンネル名]
.set 残凸把握板 #[残凸把握板のチャンネル名]
```

## コマンド一覧

英語コマンド，日本語コマンド両方を用意しています．使いやすい方を用いて下さい．適切に処理が実行されるとBotが`👍`で返事をします．

- 凸管理の開始 `.start`　`.開始`

- 凸管理を途中から開始 `.start [周回数] [ボス番号]`　`.開始 [周回数] [ボス番号]`

- 凸予約 `.reserve [ボス番号] [予定ダメージ]`　`.予約 [ボス番号] [予定ダメージ]`

- 持ち越しで凸予約 `.reserve [ボス番号] [予定ダメージ] over`　`.予約 [ボス番号] [予定ダメージ] 持ち越し`

- 凸前宣言 `.attack`　`.凸`

- 凸完了報告 `.fin [与えたダメージ]`　`.完了 [与えたダメージ]`

- 凸完了報告(LA) `la [持ち越し時間]`　`.討伐 [持ち越し時間]`

持ち越しでLAをした場合には持ち越し時間は記入しない

- 体力調整 `.adjust [現在のボスの残HP]`　`.調整 [現在のボスの残HP]`


以下の二つは予約がない時や，予約者が来ない時を想定
- 現在のボスに予約なしで凸 `.attack [予定ダメージ]`　`.凸 [予定ダメージ]`

- 現在のボスに予約なしで持ち越し凸 `.attack [予定ダメージ] over`　`.凸 [予定ダメージ] 持ち越し`


## 進行の流れ

1. `.start`または`.開始`で凸管理を開始する
2. `.reserve` または`.予約`コマンドで凸予約をする
3. 自分の番のボスが来たら `.attack`または`.凸`コマンドで凸前宣言をして凸する
4. `.fin` または `.完了`コマンドで凸完了報告する
5. ボスを討伐したら`.la`または`.討伐`コマンドで凸完了報告と持ち越し時間の報告をする．
6. 2.から5.を繰り返す

## 残凸管理

残凸管理は全自動で行います.
凸完了報告がなされた際に，残凸把握板にある数字が減って行きます．
持ち越しをした際には，持ち越しをしたボスと持ち越し時間が記録されて，さらにもう一回凸完了報告がなされると，持ち越しを消化されたと見なされて持ち越しが消去され残凸数が減ります．

日付が変わってから凸予約や予約なし凸がなされると，残凸把握板を初期化して残凸数が復活します．