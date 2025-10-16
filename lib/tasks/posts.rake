namespace :posts do
  desc "List recent posts"
  task :list => :environment do
    Post.order(created_at: :desc).limit(10).each do |post|
      puts "📝 ID: #{post.id}"
      puts "📄 Content: #{post.content}"
      puts "🖼️ Image public_id: #{post.image_public_id}"
      puts "📅 Created at: #{post.created_at}"
      puts "-----------------------------"
    end
  end
end