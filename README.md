The-View
openAIを使った自動シフト作成サイトです。
人数が多い場合、考える手間が省けるようにAIがシフトを自動生成してくれます。

URL
https://enigmatic-harbor-11430-16ff2ed55fb4.herokuapp.com/
画面中部のゲストログインボタンから、メールアドレスとパスワードを入力せずにログインできます。

使用技術
フレームワークとコア機能
Ruby 3.0.4
Ruby on Rails 6.1.3.2
Webpacker 5.0
Puma 
フロントエンド
Sass Rails
開発・テストツール
RSpec
Factory Bot Rails
Faker
Pry Rails
Rubocop
Capybara
Selenium Webdriver 
データベース
PostgreSQL
認証・ファイル管理
Devise
Carrierwave
API
ruby-openAI API
その他
Docker/Docker-compose
CircleCi 
AWS構成図
スクリーンショット 2020-05-07 11 14 01

CircleCi 
Githubへのpush時に、RspecとRubocopが自動で実行されます。
ブランチへのpushでは、RspecとRubocopが成功した場合、HEROKUへの自動デプロイが実行されます

機能一覧
ユーザー登録、ログイン機能(devise)
アカウント情報、詳細機能(user)
シフト作成,一覧機能(shift)

テスト
RSpec
単体テスト(model)
機能テスト(request)
統合テスト(system)
