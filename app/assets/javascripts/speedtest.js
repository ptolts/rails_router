Speedtest.prototype.fastJSON = function(){
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

function Speedtest(data) {
    data = data || {};

    var self = this;
    self.id = ko.observable(data.id);
    self.upRate = ko.observable(data.upRate);
    self.downRate = ko.observable(data.downRate);

    self.speedtest_saving = ko.observable(false);
    self.save = function(){
        $.ajax({
            type: "POST",
            url: "/speedtest/save",
            data: {
                data:self.fastJSON()
            },
            beforeSend: function(){
                self.speedtest_saving(true);
            },
            success: function(data, textStatus, jqXHR){
                self.speedtest_saving(false);
                self.id(data.id);
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) { 
                alert(errorThrown);
                self.speedtest_saving(false);
            },
            dataType: "json"
        }); 
    }   
        
}