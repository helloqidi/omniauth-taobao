# lots of stuff taken from https://github.com/intridea/omniauth/blob/0-3-stable/oa-oauth/lib/omniauth/strategies/oauth2/taobao.rb
require 'omniauth-oauth2'
module OmniAuth
  module Strategies
    class Taobao < OmniAuth::Strategies::OAuth2
      USER_METHODS = {
        :default => 'taobao.user.get',
        :buyer => 'taobao.user.buyer.get',
        :seller => 'taobao.user.seller.get'
      }

      USER_RESPONSE = {
        :default => 'user_get_response',
        :buyer => 'user_buyer_get_response',
        :seller => 'user_seller_get_response'
      }

      option :client_options, {
        :authorize_url => 'https://oauth.taobao.com/authorize',
        :token_url => 'https://oauth.taobao.com/token',
      }
      def request_phase
        options[:state] ||= '1'
        super
      end

      uid { raw_info['uid'] }

      info do
        {
          'uid' => raw_info['uid'],
          'nickname' => raw_info['nick'],
          'email' => raw_info['email'],
          'user_info' => raw_info,
          'extra' => {
            'user_hash' => raw_info,
          },
        }
      end

      def raw_info
        url = 'http://gw.api.taobao.com/router/rest'

        user_type = options.client_options.user_type || :default
        query_param = {
          :app_key => options.client_id,

          # TODO to be moved in options
          # TODO add more default fields (http://my.open.taobao.com/apidoc/index.htm#categoryId:1-dataStructId:3)
          :fields => 'user_id,uid,nick,sex,buyer_credit,seller_credit,location,created,last_visit,birthday,type,status,alipay_no,alipay_account,alipay_account,email,consumer_protection,alipay_bind',
          :format => 'json',
          :method => USER_METHODS[user_type],
          :session => @access_token.token,
          :sign_method => 'md5',
          :timestamp   => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
          :v => '2.0'
        }
        query_param = generate_sign(query_param)
        res = Net::HTTP.post_form(URI.parse(url), query_param)
        response = MultiJson.decode(res.body)
        raise OmniAuth::Error.new(response['error_response']) if response.has_key?('error_response')
        @raw_info ||= response[USER_RESPONSE[user_type]]['user']
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end
      
      def generate_sign(params)
        # params.sort.collect { |k, v| "#{k}#{v}" }
        str = options.client_secret + params.sort {|a,b| "#{a[0]}"<=>"#{b[0]}"}.flatten.join + options.client_secret
        params['sign'] = Digest::MD5.hexdigest(str).upcase!
        params
      end
    end
  end
end