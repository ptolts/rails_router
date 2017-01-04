var vpns;
var qoses;

function DashboardModel(){
	var self = this;
    self.hosts = ko.observableArray([]);
    self.host = ko.observable();
    self.speedtest = ko.observable();
    self.vpns = ko.observableArray([]);
    self.qoses = ko.observableArray([]);
    vpns = self.vpns;
    qoses = self.qoses;
    
    self.fetch_hosts = function(){
        $.ajax({
            type: "POST",
            url: "/host/all",
            success: function(data, textStatus, jqXHR){
                _.each(data,function(host){
                    var host_object = _.find(self.hosts(), function(h){ console.log(host.id + "==" + h.id()); return host.id == h.id() });
                    if(!host_object){
                        self.hosts.push(new Host(host));
                    } else {
                        host_object.update(host);
                    }
                });
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) { 

            },
            dataType: "json"
        });
    }

    self.fetch_host = function(){
        $.ajax({
            type: "POST",
            url: "/host/self",
            success: function(data, textStatus, jqXHR){
                self.host(new Host(data));
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) { 

            },
            dataType: "json"
        });
    }

    self.fetch_speedtest = function(){
        $.ajax({
            type: "POST",
            url: "/speedtest/fetch",
            success: function(data, textStatus, jqXHR){
                self.speedtest(new Speedtest(data));
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) { 

            },
            dataType: "json"
        });
    }    

    self.fetch_vpns = function(){
        $.ajax({
            type: "POST",
            url: "/vpn/all",
            success: function(data, textStatus, jqXHR){
                self.vpns(_.map(data,function(vpn){ return new Vpn(vpn) }));
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) { 

            },
            dataType: "json"
        });
    }

    self.fetch_qoses = function(){
        $.ajax({
            type: "POST",
            url: "/qos/all",
            success: function(data, textStatus, jqXHR){
                self.qoses(_.map(data,function(qos){ return new Qos(qos) }));
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) { 

            },
            dataType: "json"
        });
    }      
  
}

           				
