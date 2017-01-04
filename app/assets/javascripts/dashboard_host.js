var vpns;

function DashboardHost(){
	var self = this;
    DashboardModel.apply(self);
    self.fetch_host();
    self.fetch_qoses();
    self.fetch_vpns();
}

           				
