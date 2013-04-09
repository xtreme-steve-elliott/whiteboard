class BlogPost
  attr_accessor :title, :body, :keywords, :categories

  def post_hash
    {
      'title' => title,
      'description' => body,
      'mt_keywords' => keywords,
      'categories' => categories
    }
  end

  def keywords
    @keywords || []
  end

  def categories
    @categories || ['standup']
  end
end