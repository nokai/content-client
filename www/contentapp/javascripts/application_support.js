var app = {

    setContentData: function(data) {
        this.data = data;
    },
    
    setContentDataFromJSONString: function(dataAsJSONString) {
        this.data = JSON.parse(dataAsJSONString);
    },
    

    getContentData: function() {
        return this.data;
    },
    
    getContentDataAsJSONString: function() {
        return JSON.stringify(this.data);
    },
    
    onOrientationChanged: function(fn) {
        if (!this.orientationChangedCallbacks) {
            this.orientationChangedCallbacks = [];
        }
        
        this.orientationChangedCallbacks.push(fn);
    },
    
    orientationChanged: function() {
        if (this.orientationChangedCallbacks) {
            $.each(this.orientationChangedCallbacks, function(idx, fn) {
                fn();
            });
        }
    }

};

jQuery(function($) {
    //alert('hello from application_support.js');
});