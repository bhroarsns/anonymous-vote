# Anonyumous-vote

Anonymous-voteは、オンラインで匿名かつメールアドレス一つにつき一票を実現する投票システムです。

他の媒体で実現できない点として

+ 匿名投票であり、他の参加者はもちろん主催者にも参加者の投票先は分からないこと
+ 投票進行中に現在の得票状況が見えないこと

があります。

## 使用技術
+ 使用言語: Ruby
+ フレームワーク: Ruby on Rails

### 詳細(gemなど)
+ devise(ユーザー認証, 投票者の認証はbcryptのみ)
+ Pundit(認可)
+ Bootstrap使用(cssbundling-rails経由)

## スクリーンショット
### トップページ
![トップページの画像](/screenshots/pages/toppage.png)

### 投票画面
![投票画面の画像](/screenshots/pages/voting.png)

### 参加者管理画面
![参加者管理画面の画像](/screenshots/features/voters/all_delivered.png)

その他の画像は/screenshotsを御覧ください.