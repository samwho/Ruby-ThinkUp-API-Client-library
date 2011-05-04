require 'json'
require 'net/http'

class ThinkUpAPI
  attr_reader :last_response_code, :last_error, :last_args, :last_url

  def initialize(thinkup_url)
    @thinkup_base_url = thinkup_url
    @post_api_url = "#{@thinkup_base_url}api/v1/post.php?"
    @last_response_code = nil
    @last_error = {:type => nil, :message => nil}
    @last_args = nil
    @last_url = nil
  end

  # Gets posts from a specific user. The information is returned as an array of parsed JSON.
  #
  # Official documentation: http://thinkupapp.com/docs/userguide/api/posts/user_posts.html
  #
  # The optional_args argument is for optional arguments to this API call and it needs to be a hash. If anything other
  # than a hash is supplied, the argument will be ignored.
  def get_user_posts(username, optional_args = nil)
    post_api_call('user_posts', {'username' => username}, optional_args)
  end

  # Gets posts from a specific user in a specific time range. The information is returned as an array of parsed JSON.
  #
  # Official documentation: http://thinkupapp.com/docs/userguide/api/posts/user_posts_in_range.html
  #
  # The optional_args argument is for optional arguments to this API call and it needs to be a hash. If anything other
  # than a hash is supplied, the argument will be ignored.
  def get_user_posts_in_range(username, from, to, optional_args = nil)
    post_api_call('user_posts_in_range', {'username' => username, :from => from, :to => to}, optional_args)
  end

  # Gets posts that are questions from a specific user. The information is returned as an array of parsed JSON.
  #
  # Official documentation: http://thinkupapp.com/docs/userguide/api/posts/user_questions.html
  #
  # The optional_args argument is for optional arguments to this API call and it needs to be a hash. If anything other
  # than a hash is supplied, the argument will be ignored.
  def get_user_questions(username, optional_args = nil)
    post_api_call('user_questions', {'username' => username}, optional_args)
  end

  # Gets posts that are replies to a specific user. The information is returned as an array of parsed JSON.
  #
  # Official documentation: http://thinkupapp.com/docs/userguide/api/posts/user_replies.html
  #
  # The optional_args argument is for optional arguments to this API call and it needs to be a hash. If anything other
  # than a hash is supplied, the argument will be ignored.
  def get_user_replies(username, optional_args = nil)
    post_api_call('user_replies', {'username' => username}, optional_args)
  end

  # Gets posts that are mentions of a specific user. The information is returned as an array of parsed JSON.
  #
  # Official documentation: http://thinkupapp.com/docs/userguide/api/posts/user_mentions.html
  #
  # The optional_args argument is for optional arguments to this API call and it needs to be a hash. If anything other
  # than a hash is supplied, the argument will be ignored.
  def get_user_mentions(username, optional_args = nil)
    post_api_call('user_mentions', {'username' => username}, optional_args)
  end

  # Gets most replied to posts from a specific user. The information is returned as an array of parsed JSON.
  #
  # Official documentation: http://thinkupapp.com/docs/userguide/api/posts/user_posts_most_replied_to.html
  #
  # The optional_args argument is for optional arguments to this API call and it needs to be a hash. If anything other
  # than a hash is supplied, the argument will be ignored.
  def get_user_posts_most_replied_to(username, optional_args = nil)
    post_api_call('user_posts_most_replied_to', {'username' => username}, optional_args)
  end

  # Gets most retweeted posts from a specific user. The information is returned as an array of parsed JSON.
  #
  # Official documentation: http://thinkupapp.com/docs/userguide/api/posts/user_posts_most_retweeted.html
  #
  # The optional_args argument is for optional arguments to this API call and it needs to be a hash. If anything other
  # than a hash is supplied, the argument will be ignored.
  def get_user_posts_most_retweeted(username, optional_args = nil)
    post_api_call('user_posts_most_retweeted', {'username' => username}, optional_args)
  end

  # Gets a specific post. The information is returned as parsed JSON.
  #
  # Official documentation: http://thinkupapp.com/docs/userguide/api/posts/post.html
  #
  # The optional_args argument is for optional arguments to this API call and it needs to be a hash. If anything other
  # than a hash is supplied, the argument will be ignored.
  def get_post(post_id, optional_args = nil)
    post_api_call('post', {'post_id' => post_id}, optional_args)
  end

  # Gets replies to a specific post. The information is returned as an array of parsed JSON.
  #
  # Official documentation: http://thinkupapp.com/docs/userguide/api/posts/post_replies.html
  #
  # The optional_args argument is for optional arguments to this API call and it needs to be a hash. If anything other
  # than a hash is supplied, the argument will be ignored.
  def get_post_replies(post_id, optional_args = nil)
    post_api_call('post_replies', {'post_id' => post_id}, optional_args)
  end

  # Gets retweets of a specific post. The information is returned as an array of parsed JSON.
  #
  # Official documentation: http://thinkupapp.com/docs/userguide/api/posts/post_retweets.html
  #
  # The optional_args argument is for optional arguments to this API call and it needs to be a hash. If anything other
  # than a hash is supplied, the argument will be ignored.
  def get_post_retweets(post_id, optional_args = nil)
    post_api_call('post_retweets', {'post_id' => post_id}, optional_args)
  end

  # Gets posts related to a specific post. The information is returned as an array of parsed JSON.
  #
  # Official documentation: http://thinkupapp.com/docs/userguide/api/posts/related_posts.html
  #
  # The optional_args argument is for optional arguments to this API call and it needs to be a hash. If anything other
  # than a hash is supplied, the argument will be ignored.
  def get_related_posts(post_id, optional_args = nil)
    post_api_call('related_posts', {'post_id' => post_id}, optional_args)
  end

  private

  # Takes a hash of key=value pairs and formats them into arguments for a URL.
  def expand_args (args)
    # if the argument is a Hash, expand it into an argument string: key=value
    if args.class == Hash
      expanded = ''
      args.each {|key, value| expanded += "&" + key.to_s + "=" + value.to_s}
      return expanded
    else
      return ''
    end
  end

  # Issues an API call and returns an array of parsed JSON.
  #
  # If the API call fails for whatever reason (API error, 404, etc.) nil is returned and various debugging info can be
  # found in last_error, last_response_code and last_args.
  def post_api_call(type, required_args, optional_args = nil)
    # Merge the required and optional argument hashes.
    if required_args.is_a?(Hash) and optional_args.is_a?(Hash)
      args = required_args.merge(optional_args)
    elsif required_args.is_a?(Hash)
      args = required_args
    elsif optional_args.is_a?(Hash)
      args = optional_args
    end

    url = "#{@post_api_url}type=#{type}#{expand_args(args)}"
    resp = Net::HTTP.get_response(URI.parse(url))

    @last_response_code = resp.code
    @last_url = url
    @last_args = args

    if resp.code == "200"
      parsed_response = JSON.parse(resp.body)
      if parsed_response.is_a?(Hash) and parsed_response.has_key?('error')
        @last_error[:type] = parsed_response['type']
        @last_error[:message] = parsed_response['message']
        return nil
      else
        return parsed_response
      end
    else
      return nil
    end
  end
end
