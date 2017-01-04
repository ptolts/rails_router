var vpns;

function DashboardHosts(){
	var self = this;
    DashboardModel.apply(self);
    self.fetch_hosts();
    self.fetch_vpns();
    self.fetch_qoses();
    self.interval = setInterval(self.fetch_hosts, 30000);
}

           				
