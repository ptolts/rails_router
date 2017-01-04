Host.prototype.fastJSON = function(){
    var fast = {};
    for (var property in this) {
        if (this.hasOwnProperty(property)) {
            var result = this[property];
            while(ko.isObservable(result)){
                result = result.peek();
            }
            if(typeof result == "function"){
                continue;
            }
            if(typeof result == "object"){
                if(result == null){
                    fast[property] = result;
                    continue;
                }                
                if(property == "vpn"){
                    fast[property] = result.id();
                    continue;
                }                                           
                if(Array.isArray(result)){
                    continue;
                }
                if(result.fastJSON){
                    continue;
                }
            }         
            fast[property] = result;
        }
    } 
    return JSON.stringify(fast);    
}

function Host(data) {
    data = data || {};

    var self = this;
    self.id = ko.observable(data.id);
    self.hostname = ko.observable(data.hostname ? data.hostname : "");
    self.ip_address = ko.observable(data.ip_address ? data.ip_address : "");
    self.card_type = ko.observable(data.card_type ? data.card_type : "");
    self.mac_address = ko.observable(data.mac_address ? data.mac_address : "");
    self.seen_count = ko.observable(data.seen_count ? data.seen_count : 0);
    self.online = ko.observable(data.online ? data.online : false);
    
    self.vpn_id = ko.observable(data.vpn_id);
    self.vpn = ko.computed(function(){
        if(self.vpn_id()){
            var selected_vpn = _.find(vpns(),function(v){ return v.id() == self.vpn_id() });
            if(selected_vpn){
                return selected_vpn;
            } else {
                return null;
            }
        } else {
            return null;
        }
    });

    self.qos_id = ko.observable(data.qos_id);
    self.qos = ko.computed(function(){
        if(self.qos_id()){
            var selected_qos = _.find(qoses(),function(v){ return v.id() == self.qos_id() });
            if(selected_qos){
                return selected_qos;
            } else {
                return null;
            }
        } else {
            return null;
        }
    });    

    self.update = function(data){
        self.hostname(data.hostname ? data.hostname : "");
        self.ip_address(data.ip_address ? data.ip_address : "");
        self.card_type(data.card_type ? data.card_type : "");
        self.mac_address(data.mac_address ? data.mac_address : "");
        self.seen_count(data.seen_count ? data.seen_count : 0);
        self.online(data.online ? data.online : false);
    }

    self.host_saving = ko.observable(false);
    self.save = function(){
        $.ajax({
            type: "POST",
            url: "/host/save",
            data: {
                data:self.fastJSON()
            },
            beforeSend: function(){
                self.host_saving(true);
            },
            success: function(data, textStatus, jqXHR){
                self.host_saving(false);
                self.id(data.id);
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) { 
                alert(errorThrown);
                self.host_saving(false);
            },
            dataType: "json"
        }); 
    }

    self.dirtyTrack = ko.computed(function(){
        self.vpn_id();
        self.qos_id();
        if(!ko.computedContext.isInitial()){
            self.save();    
        }
    }).extend({ notify: 'always', rateLimit: 0 });    
        
}