module ApplicationHelper
  include MetaTags::ViewHelper

  def kind_icon(kind)
    case kind.to_s
    when "cool"     then "😎"
    when "cute"     then "💖"
    when "stylish"  then "✨"
    when "healing"  then "🌿"
    when "aesthetic" then "📸"
    else "⭐"
    end
  end

  def kind_label(kind)
    case kind.to_s
    when "cool"     then "かっこいい"
    when "cute"     then "かわいい"
    when "stylish"  then "スタイリッシュ"
    when "healing"  then "癒し系"
    when "aesthetic" then "映える"
    else kind.to_s
    end
  end

  def full_title(page_title = "")
    base_title = "PCPACK"
    page_title.present? ? "#{page_title} | #{base_title}" : base_title
  end

  def default_meta_tags
    {
      site: "PCPACK",
      title: "PCPACK - あなたの創造を形にする",
      description: "PCPACKはPCの部屋や仕事部屋を魅せるためのプラットフォームです。",
      og: {
        title: :title,
        description: :description,
        image: "https://res.cloudinary.com/dqjb4apad/image/upload/v1763618882/web_ogp_oyika6.png",
        url: request.original_url
      },
      twitter: {
        card: "summary_large_image",
        image: "https://res.cloudinary.com/dqjb4apad/image/upload/v1763618882/web_ogp_oyika6.png"
      }
    }
  end
end
