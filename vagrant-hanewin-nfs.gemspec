$:.unshift File.expand_path("../lib", __FILE__)
require "vagrant-hanewin-nfs/version"

Gem::Specification.new do |gem|
  gem.name    = 'vagrant-hanewin-nfs'
  gem.version = VagrantPlugins::VagrantHanewinNfs::VERSION

  gem.summary     = 'Adds NFS support for Windows with Hanewin NFS'
  gem.description = <<-EOD
    Manage and adds support for NFS on windows.
  EOD

  gem.authors  = 'Christian Simon'
  gem.email    = 'simon@swine.de'
  gem.homepage = 'https://github.com/simonswine/vagrant-hanewin-nfs'

  gem.has_rdoc = true
  gem.license  = 'Apache 2.0'

  # The following block of code determines the files that should be included
  # in the gem. It does this by reading all the files in the directory where
  # this gemspec is, and parsing out the ignored files from the gitignore.
  # Note that the entire gitignore(5) syntax is not supported, specifically
  # the "!" syntax, but it should mostly work correctly.
  root_path      = File.dirname(__FILE__)
  all_files      = Dir.chdir(root_path) { Dir.glob("**/{*,.*}") }
  all_files.reject! { |file| [".", ".."].include?(File.basename(file)) }
  gitignore_path = File.join(root_path, ".gitignore")
  gitignore      = File.readlines(gitignore_path)
  gitignore.map!    { |line| line.chomp.strip }
  gitignore.reject! { |line| line.empty? || line =~ /^(#|!)/ }

  unignored_files = all_files.reject do |file|
    # Ignore any directories, the gemspec only cares about files
    next true if File.directory?(file)

    # Ignore any paths that match anything in the gitignore. We do
    # two tests here:
    #
    #   - First, test to see if the entire path matches the gitignore.
    #   - Second, match if the basename does, this makes it so that things
    #     like '.DS_Store' will match sub-directories too (same behavior
    #     as git).
    #
    gitignore.any? do |ignore|
      File.fnmatch(ignore, file, File::FNM_PATHNAME) ||
          File.fnmatch(ignore, File.basename(file), File::FNM_PATHNAME)
    end
  end

  gem.files        = unignored_files
  gem.require_path = 'lib'
end
