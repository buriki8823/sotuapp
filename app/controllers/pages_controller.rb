class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:terms, :privacy_policy, :ogp_static, :home]

  def terms
  end

  def privacy_policy
  end

  def ogp_static
    @ogp_title = "PCPACK - あなたの創造を形にする"
    @ogp_description = "PCPACKはPCの部屋や仕事部屋を魅せるためのプラットフォームです。"
    @ogp_image_url = "https://res.cloudinary.com/dqjb4apad/image/upload/v1763618882/web_ogp_oyika6.png"

    set_meta_tags title: @ogp_title,
                  description: @ogp_description,
                  og: {
                    title: @ogp_title,
                    description: "あなたのPC部屋や仕事部屋を美しく共有しよう。",
                    image: @ogp_image_url,
                    url: request.original_url
                  },
                  twitter: {
                    card: "summary_large_image",
                    image: @ogp_image_url
                  }
  end
end
