# TODOs

* handle disconnects
* handle network changes - e.g. wifi -> 3g.  use reachability
* option to restrict downloads to wifi only
* URL handler (interapp communication) ?contentid=<id>, ?contentname=<name>
* application updates - compare version in manifest on server to client version
* tilte content posters for browsing
* targeted content based on device id (is there a backend system that has [isid | username] -> deviceid)
* use blocks for ContentManager. e.g. [contentManager setCompletionBlock:^(NSDictionary *info) { }];

* allow content item to specify it wants to lock to an orientation. e.g. landscape mode only

* horizontal swipable presentation mode.  e.g. 5 slides.  each slide is loaded in a UIWebView.  all 5 UIWebViews are contained in a side scrolling scrollview
    * gesture to display tiled thumbnail selection view. e.g. 5 UIWebViews are displayed on single page