### How to make it work with Taobao

#### API permission levels

Taobao has three API permission levels
 
* Default API (Requires additional approval from Taobao)
* Buyer API 
* Seller API

These permission levels are granted during your app application process based on your app type.
To configure omniauth-taobao work with the correct type, please use something like this (omniauth + device example in devise.rb file):

```
config.omniauth :taobao, "Your_APP_Key", "Your_APP_Secret", :strategy_class => OmniAuth::Strategies::Taobao, :client_options => {:user_type => :seller}

```

The ```:user_type``` option can be one of ```:default```,```:buyer``` and ```:seller```.

#### User Get Info Response

Different API Permission levels needs to use different API to obtain user's info.

The documentation for these API can be found [here](http://open.taobao.com/doc/api_cat_detail.htm?spm=0.0.0.0.JJ4lrk&cat_id=1&category_id=102) 

omniauth-taobao will chose the proper API method based on your ```:user_type```  option.

#### Sample API Response (For Seller API)

```
--- !ruby/hash:OmniAuth::AuthHash
provider: taobao
uid:
info: !ruby/hash:OmniAuth::AuthHash::InfoHash
  uid:
  nickname: UserNickName
  email:
  user_info: !ruby/hash:OmniAuth::AuthHash
    alipay_bind: bind
    consumer_protection: true/false
    nick: UserNickName
    seller_credit: !ruby/hash:OmniAuth::AuthHash
      good_num: 7
      level: 1
      score: 7
      total_num: 7
    sex: m
    status: normal
    type: C
    user_id: 1212121212
  extra: !ruby/hash:OmniAuth::AuthHash
    user_hash: !ruby/hash:OmniAuth::AuthHash
      alipay_bind: bind
      consumer_protection: true
      nick: UserNickName
      seller_credit: !ruby/hash:OmniAuth::AuthHash
        good_num: 7
        level: 1
        score: 7
        total_num: 7
      sex: m
      status: normal
      type: C
      user_id: 1212121212
credentials: !ruby/hash:OmniAuth::AuthHash
  token: Token
  refresh_token: refresh_token
  expires_at: 13722222220
  expires: true
extra: !ruby/hash:OmniAuth::AuthHash {}
```