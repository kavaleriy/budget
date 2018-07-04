namespace :documentation do
  desc "del clone branch"
  task :unique_branch, [:first_branch, :second_branch] => :environment do |_task, args|
    second_branch = Documentation::Branch.find(args[:second_branch])
    p "#{second_branch.document_category.size} second_branch documents will be transform!"

    second_branch.document_category.each do |document|
      document.branch = args[:first_branch]
      document.save
    end

    p "#{second_branch.document_category.size} second_branch documents exist!"
    second_branch.delete
  end
end
