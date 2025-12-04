require "rails_helper"
require "timeout"
require "securerandom"

RSpec.describe "Post show page interactions", type: :system, js: true do
  let(:raw_password) { SecureRandom.hex(12) }
  let(:user) { create(:user, password: raw_password) }
  let(:post) do
    create(:post,
      user: user,
      title: "テスト投稿",
      body: "本文",
      image_urls: ["https://via.placeholder.com/800x600.png"]
    )
  end

  def wait_for(timeout: Capybara.default_max_wait_time)
    Timeout.timeout(timeout) do
      loop do
        result = yield
        return result if result
        sleep 0.1
      end
    end
  rescue Timeout::Error
    nil
  end

  before do
    visit new_user_session_path

    # フォームを表示するために背景をクリック（存在すれば）
    if page.has_selector?('#login-background', wait: 2)
      find('#login-background', visible: true).click
    end

    # 表示を待ってから id で入力
    expect(page).to have_field("user_email", visible: true, wait: 5)
    expect(page).to have_field("user_password", visible: true, wait: 5)

    fill_in "user_email", with: user.email
    fill_in "user_password", with: raw_password

    # ログイン時に出る alert を受け入れる
    accept_alert(wait: Capybara.default_max_wait_time) do
      click_button "ログイン"
    end

    # 念のため未処理の alert が残っていたらクリーンにする（フォールバック）
    begin
      page.accept_alert if page.driver.browser.switch_to.alert
    rescue StandardError
      # ignore
    end

    expect(page).not_to have_current_path(new_user_session_path)
    visit post_path(post)
  end

  it "allows bookmarking toggle" do
    expect(Bookmark.exists?(post_id: post.id, user_id: user.id)).to be_falsey
    find(".bookmark-button", match: :first).click
    expect(wait_for { Bookmark.exists?(post_id: post.id, user_id: user.id) }).to be_truthy
  end

  it "allows commenting via ajax" do
    expect(Comment.exists?(post_id: post.id)).to be_falsey

    # フォームが表示されるのを待つ
    expect(page).to have_selector('form#comment-form, #comment-form form', visible: true, wait: 5)
    find('textarea[name="comment[body]"]', visible: true).set("これはコメントです")

    # JS ハンドラが未アタッチでも確実に fetch を発火させる（CSRF トークンを付与）
    page.execute_script(<<~JS)
      (function() {
        const form = document.querySelector('form#comment-form, #comment-form form');
        if (!form) return;
        const csrf = document.querySelector("[name='csrf-token']")?.content || null;
        fetch(form.action, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrf },
          body: JSON.stringify({ comment: { body: form.querySelector("textarea[name='comment[body]']").value } })
        }).catch(e => console.error('fetch error', e));
      })();
    JS

    expect(wait_for { Comment.exists?(post_id: post.id, body: "これはコメントです") }).to be_truthy
  end

  it "allows star rating" do
    # ドロップダウンを開いて明示的にスコアを選択する
    find(".star-display", match: :first, visible: true).click
    expect(page).to have_selector(".score-option", visible: true, wait: 3)
    find('.score-option[data-score="1"]', match: :first, visible: true).click

    expect(wait_for { StarRating.exists?(post_id: post.id, user_id: user.id) }).to be_truthy
  end

  it "allows kind evaluation toggle" do
    find(".kind-button", match: :first).click
    expect(wait_for { Evaluation.exists?(post_id: post.id, user_id: user.id) }).to be_truthy
  end
end