require 'rake'
require 'rake/clean'

namespace(:devkit) do
  namespace(:msys) do
    package = DevKitInstaller::MSYS
    directory package.target
    CLEAN.include(package.target)

    package.files.each do |k,v|
      v.each do |f|
        #TODO handle exception when no corresponding URL defined on package
        file_source = "#{package.send(k)}/#{f}"
        file_target = "downloads/#{f}"
        download file_target => file_source

        # depend on downloads directory
        file file_target => "downloads"

        # download task needs the packages files as pre-requisites
        task :download => file_target
      end
    end

    task :extract => [:extract_utils, :download, package.target] do
      # extract each of the packages files into the target dir
      # if archive passes 7-Zip integrity test
      Rake::Task['devkit:msys:download'].prerequisites.each do |f|
        fail "[FAIL] corrupt '#{f}' archive" unless seven_zip_valid?(f)
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      end
    end

    task :prepare do
      #TODO verify whether need to comment out 'cd $HOME' from /etc/profile
    end

  end

  task :msys => ['devkit:msys:download', 'devkit:msys:extract']
end
