require Vagrant.source_root.join("plugins/synced_folders/nfs/synced_folder")

module VagrantPlugins
  module VagrantHanewinNfs
    class SyncedFolder < VagrantPlugins::SyncedFolderNFS::SyncedFolder
        def usable?(machine,raise_error=false)
            return true
        end
    end
  end
end
