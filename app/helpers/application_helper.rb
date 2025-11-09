module ApplicationHelper
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
end