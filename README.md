## 準備

Railsアプリの新規作成

```
$ rails new rails-devise-cancancan -d postgresql -T --skip-bundle
```

Gemのインストール

```
# Gemfile

...
gem 'devise'
gem 'cancancan'
...
```

```
$ bundle install --path vendor/bundle
```


DBの作成

```
$ bundle exec rake db:create
```

deviseのインストール

```
$ rails g devise:install
```

JSONでのレスポンスに対応

```
# config/application.rb

module DeviseApiUse
  class Application < Rails::Application
    ...
    config.to_prepare do
      DeviseController.respond_to :html, :json
    end
    ...
  end
end
```

## モデル

マイグレーションファイルの作成

```
$ rails g devise user
```


カラム追加(認証トークン)

```
#  db/migrate/xxxxx__devise_create_users.rb
# (db/migrate/20170408094212_devise_create_users.rb)

class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      ...
      ## 認証トークン
      t.string :authentication_token
      ...
    end
  end
end

```

マイグレーションの実行

```
$ bundle exec rake db:migrate
```

モデルの編集

```
# app/models/user.rb

class User < ActiveRecord::Base
  ...
  # 認証トークンはユニークに。ただしnilは許可
  validates:authentication_token, uniqueness: true, allow_nil: true
  has_many :notes

  # 認証トークンが無い場合は作成
  def ensure_authentication_token
    self.authentication_token || generate_authentication_token
  end

  # 認証トークンの作成
  def generate_authentication_token
    loop do
      old_token = self.authentication_token
      token = SecureRandom.urlsafe_base64(24).tr('lIO0', 'sxyz')
      break token if (self.update!(authentication_token: token) rescue false) && old_token != token
    end
  end

  # 認証トークンの削除
  def delete_authentication_token
    self.update(authentication_token: nil)
  end
  ...
end
```

## コントローラー

JSONのリクエストの場合CSRFの検証をしない

```
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  ...
  # jsonでのリクエストの場合CSRFトークンの検証をスキップ
  skip_before_action :verify_authenticity_token, if: -> {request.format.json?}
  ...
end
```

```
# config/routes.rb

Rails.application.routes.draw do
  ...
-  devise_for :users
+  devise_for :users, controllers: { sessions: "sessions" }
  ...
end
```

```
# app/controllers/sessions_controller.rb

class SessionsController < Devise::SessionsController
  def create
    super do |resource|
      resource.ensure_authentication_token if request.format.json?
    end
  end
end
```

ビューの編集
```
$ rails g devise:views users
```

abilityの作成
```
$ rails g cancan:ability
```
