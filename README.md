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
![トップページ](/screenshots/pages/toppage.png)