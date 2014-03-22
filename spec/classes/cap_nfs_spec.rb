require 'vagrant'
require 'vagrant-hanewin-nfs/cap/nfs'
require 'tempfile'


describe VagrantPlugins::VagrantHanewinNfs::Cap::NFS do

  before(:each) do
    @tempfile = Tempfile.new("nfs_config")
    @NFS = VagrantPlugins::VagrantHanewinNfs::Cap::NFS
    @NFS.stub(:nfs_config_file_path).and_return(@tempfile.path)

    @host = double()
    @host.stub(:capability).and_return(true)

    @env = double()
    @env.stub(:host).and_return(@host)

    @folders = {
      'test123' =>
      {
        :nfs => true,
        :hostpath => 'C:/localdev/test'
      },
    }
    @id = "208a0b6b-b713-427b-9c7f-2721ec819b80"
    @ips = ['127.0.0.1','123.45.78.19']
  end

  describe "#nfs_export" do
    context "not existing config file" do

      it {
        @NFS.stub(:nfs_config_file_path).and_return(@tempfile.path+"dasda")

        @tempfile.close
        expect { @NFS.nfs_export(
          @env,
          nil,
          @id,
          @ips,
          @folders,
        ) }.not_to raise_error

        content  = open(@NFS.nfs_config_file_path).read()
        content.should match(/C:\\localdev\\test/)

      }
    end
    context "already existing config" do
      before(:each) do
        @config_old = "C:\\localdev\\test -mapall:1000:1000 127.0.0.1 ##VAGRANT#208a0b6b-b713-427b-9c7f-2721ec819b80#\nC:\\localdev\\test -mapall:1000:1000 123.45.78.19 ##VAGRANT#208a0b6b-b713-427b-9c7f-2721ec819b80#\n"
        @tempfile.write(@config_old)
        @tempfile.flush
      end

      describe "correct config should not change" do
        it {

          expect { @NFS.nfs_export(
            @env,
            nil,
            @id,
            @ips,
            @folders,
          ) }.not_to raise_error

          content  = open(@NFS.nfs_config_file_path).read()
          content.should eq(@config_old)
        }
      end

      describe "changed ip should change config" do
        it {

          expect { @NFS.nfs_export(
            @env,
            nil,
            @id,
            ['1.2.3.4'],
            @folders,
          ) }.not_to raise_error

          content  = open(@NFS.nfs_config_file_path).read()
          content.lines.count.should eq(1)
          content.should match(/1\.2\.3\.4/)
        }
      end
    end
  end
end
