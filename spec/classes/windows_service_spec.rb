require "vagrant"
require "vagrant-hanewin-nfs/windows_service"

describe VagrantPlugins::VagrantHanewinNfs::WindowsService do

  before(:each) do
    @name = 'service1'
    @service = VagrantPlugins::VagrantHanewinNfs::WindowsService.new(@name)
    @stdout_running = "adfadf\n  STATE              : 4  RUNNING \n asds"
    @stdout_stopped = "adfadf\n  STATE              : 1  STOPPED \n asds"
    @double_open3 = double('Open3')
    stub_const("Open3", @double_open3)
  end

  describe "existing service" do
    context "is running" do
      describe '#status' do
        it {
          @double_open3.should_receive(:capture3)
          .with("sc query \"#{@name}\"")
          .and_return([@stdout_running,"",double(:exitstatus => 0)])
          @service.status.should eq("RUNNING")
        }
      end

      describe '#stop' do
        it {
          @double_open3.should_receive(:capture3)
          .with("sc stop \"#{@name}\"")
          .and_return(["","",double(:exitstatus => 0)])
          @double_open3.should_receive(:capture3)
          .with("sc query \"#{@name}\"")
          .and_return([@stdout_running,"",double(:exitstatus => 0)])
          @double_open3.should_receive(:capture3)
          .with("sc query \"#{@name}\"")
          .and_return([@stdout_stopped,"",double(:exitstatus => 0)])
          @service.stop
        }
      end

      describe '#start' do
        it {
          @double_open3.should_receive(:capture3)
          .with("sc start \"#{@name}\"")
          .and_return(["Already running","",double(:exitstatus => 32)])
          @double_open3.should_receive(:capture3)
          .with("sc query \"#{@name}\"")
          .and_return([@stdout_running,"",double(:exitstatus => 0)])
          @service.start
        }
      end
    end

    context "is not running" do
      describe '#status' do
        it {
          @double_open3.should_receive(:capture3)
          .with("sc query \"#{@name}\"")
          .and_return([@stdout_stopped,"",double(:exitstatus => 0)])
          @service.status.should eq("STOPPED")
        }
      end

      describe '#stop' do
        it {
          @double_open3.should_receive(:capture3)
          .with("sc stop \"#{@name}\"")
          .and_return(["","",double(:exitstatus => 38)])
          @double_open3.should_receive(:capture3)
          .with("sc query \"#{@name}\"")
          .and_return([@stdout_stopped,"",double(:exitstatus => 0)])
          @service.stop
        }
      end

      describe '#start' do
        it {
          @double_open3.should_receive(:capture3)
          .with("sc start \"#{@name}\"")
          .and_return(["Already running","",double(:exitstatus => 0)])
          @double_open3.should_receive(:capture3)
          .with("sc query \"#{@name}\"")
          .and_return(["UNPARSABLE","",double(:exitstatus => 0)])
          @double_open3.should_receive(:capture3)
          .with("sc query \"#{@name}\"")
          .and_return([@stdout_running,"",double(:exitstatus => 0)])
          @service.start
        }
      end
    end
  end

  describe "not existing service" do
    before(:each) do
      @name = 'service_not1'
      @service = VagrantPlugins::VagrantHanewinNfs::WindowsService.new(@name)
    end

    describe '#status' do
      it {
        @double_open3.should_receive(:capture3)
        .with("sc query \"#{@name}\"")
        .and_return([@stdout_stopped,"",double(:exitstatus => 103)])
        expect { @service.status }.to raise_error(/not found/)
      }
    end

    describe '#stop' do
      it {
        @double_open3.should_receive(:capture3)
        .with("sc stop \"#{@name}\"")
        .and_return([@stdout_stopped,"",double(:exitstatus => 36)])
        expect { @service.stop }.to raise_error(/not found/)
      }
    end

    describe '#start' do
      it {
        @double_open3.should_receive(:capture3)
        .with("sc start \"#{@name}\"")
        .and_return([@stdout_stopped,"",double(:exitstatus => 36)])
        expect { @service.start }.to raise_error(/not found/)
      }
    end
  end
end
