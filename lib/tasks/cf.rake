require 'fileutils'

ENVIRONMENT = nil

desc 'Set deployment configuration for acceptance'
task :acceptance do
  ENVIRONMENT = 'acceptance'
end

desc 'Set deployment configuration for production'
task :production do
  ENVIRONMENT = 'production'
end

desc 'Deploy on Cloud Foundry'
task :deploy => 'cf:deploy'

namespace :cf do
  task :deploy do
    raise 'Specify `rake acceptance deploy`, or `rake production deploy`' unless ENVIRONMENT
    environment = ENVIRONMENT
    cf_target = 'api.run.pivotal.io'
    deploy_space = 'whiteboard'
    deploy_org = "pivotallabs"
    deploy_repo_subdir = "tmp/cf_deploy"
    tmp_copy_dir = "/tmp/cf_deploy"

    check_for_cli

    check_for_dirty_git

    tag_deploy(environment)

    # Copy repo to tmp dir so we can continue working while it deploys
    puts "Copying repo to #{deploy_repo_subdir}..."
    FileUtils.rm_rf("#{Rails.root.to_s}/#{deploy_repo_subdir}")
    FileUtils.cp_r Rails.root.to_s, tmp_copy_dir
    FileUtils.mv tmp_copy_dir, "#{Rails.root.to_s}/#{deploy_repo_subdir}"

    # Change working directory to copied repo
    Dir.chdir("#{Rails.root.to_s}/#{deploy_repo_subdir}")

    # Delete symbolic links before deploy because cf doesn't like them
    sh 'find . -type l -exec rm -f {} \;'

    sh "cf target #{cf_target} -o #{deploy_org} -s #{deploy_space}"
    sh "cf push -m config/cf-#{environment}.yml"
  end

  def check_for_cli
    sh 'cf -v' do |ok, res|
      raise "The CloudFoundry CLI is required. Run: gem install cf" unless ok
    end
  end

  def check_for_dirty_git
    raise "Unstaged or uncommitted changes cannot be deployed! Aborting!" if `git status --porcelain`.present?
  end

  def tag_deploy env
    sh "autotag create #{env}"
  end
end
