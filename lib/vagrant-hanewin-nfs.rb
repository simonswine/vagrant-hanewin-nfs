module VagrantPlugins
  module VagrantHanewinNfs
    require 'vagrant-hanewin-nfs/version'
    require 'vagrant-hanewin-nfs/plugin'

    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end

    def self.get_nfs_dir
      Pathname.new("C:/Program Files/nfsd/")
    end

    def self.get_nfs_path(file)
      get_nfs_dir.join(file)
    end
  end
end
