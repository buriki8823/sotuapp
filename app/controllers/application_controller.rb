class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_new_message_flag


  def after_sign_in_path_for(resource)
    authenticated_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :avatar_url ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :avatar_url ])
  end

  def set_new_message_flag
    if user_signed_in?
      has_unread_messages = Message.where(recipient_id: current_user.id, read: false).exists?
      has_unread_replies  = Reply.where(recipient_id: current_user.id, read: false).exists?
      @has_new_messages = has_unread_messages || has_unread_replies
    else
      @has_new_messages = false
    end
  end

  def normalize_query(q)
    q = q.to_s.strip.downcase

    # ローマ字 → ひらがな
    romaji_map = {
      "kya"=>"きゃ","kyu"=>"きゅ","kyo"=>"きょ",
      "sha"=>"しゃ","shu"=>"しゅ","sho"=>"しょ",
      "cha"=>"ちゃ","chu"=>"ちゅ","cho"=>"ちょ",
      "nya"=>"にゃ","nyu"=>"にゅ","nyo"=>"にょ",
      "hya"=>"ひゃ","hyu"=>"ひゅ","hyo"=>"ひょ",
      "mya"=>"みゃ","myu"=>"みゅ","myo"=>"みょ",
      "rya"=>"りゃ","ryu"=>"りゅ","ryo"=>"りょ",
      "gya"=>"ぎゃ","gyu"=>"ぎゅ","gyo"=>"ぎょ",
      "ja"=>"じゃ","ju"=>"じゅ","jo"=>"じょ",
      "bya"=>"びゃ","byu"=>"びゅ","byo"=>"びょ",
      "pya"=>"ぴゃ","pyu"=>"ぴゅ","pyo"=>"ぴょ",

      "ka"=>"か","ki"=>"き","ku"=>"く","ke"=>"け","ko"=>"こ",
      "sa"=>"さ","shi"=>"し","su"=>"す","se"=>"せ","so"=>"そ",
      "ta"=>"た","chi"=>"ち","tsu"=>"つ","te"=>"て","to"=>"と",
      "na"=>"な","ni"=>"に","nu"=>"ぬ","ne"=>"ね","no"=>"の",
      "ha"=>"は","hi"=>"ひ","fu"=>"ふ","he"=>"へ","ho"=>"ほ",
      "ma"=>"ま","mi"=>"み","mu"=>"む","me"=>"め","mo"=>"も",
      "ya"=>"や","yu"=>"ゆ","yo"=>"よ",
      "ra"=>"ら","ri"=>"り","ru"=>"る","re"=>"れ","ro"=>"ろ",
      "wa"=>"わ","wo"=>"を",
      "ga"=>"が","gi"=>"ぎ","gu"=>"ぐ","ge"=>"げ","go"=>"ご",
      "za"=>"ざ","ji"=>"じ","zu"=>"ず","ze"=>"ぜ","zo"=>"ぞ",
      "da"=>"だ","de"=>"で","do"=>"ど",
      "ba"=>"ば","bi"=>"び","bu"=>"ぶ","be"=>"べ","bo"=>"ぼ",
      "pa"=>"ぱ","pi"=>"ぴ","pu"=>"ぷ","pe"=>"ぺ","po"=>"ぽ",

      "a"=>"あ","i"=>"い","u"=>"う","e"=>"え","o"=>"お",
      "n"=>"ん"
    }

    hira = q.dup
    romaji_map.keys.sort_by { |k| -k.length }.each do |roma|
      hira.gsub!(roma, romaji_map[roma])
    end

    # カタカナ → ひらがな
    hira = hira.tr("ァ-ン", "ぁ-ん")

    hira
  end
end
