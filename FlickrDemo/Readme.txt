
Libraries used
=================
SVProgressHUD
 - This library is included in the project to give feedback to users when making long running operations. This libary is easy to use
   and you dont need to specify the view where it should appear, this class go throught the view hirerchary and locate the custom view on the top
   view currently displayed. It have minimun configuration but perform great.

DPNotify
 - This class show a message allowing make custom colors, type, configurations, etc. it allow to dissapear automatically or manually on view tap.
    Its in swift and some of the methods does not work on objective-c because in swift have the same signature.

KSReachability
 - Simple tu use and started on the app launch perform a check against a indicated host to check if is reachable. Its great to use because is quite small and use block to notify about network changes.



Extensions
===============
NSdate+Helper

Great extension to handle common date operations.



General App architecture notes:


BCBaseOperation
------------------------------------------------------------------------
The app use NSOperation to interact with Flickr endpoints.

BCBaseOperation
  |
  |- resource   - resource to access (user_id, photo_id, etc..)
  |- predicate  - endpoint (flickr.photos.getSizes, flickr.photos.getInfo, etc)
  |- session    - the global session for the app
  |- result     - result for the opration
  |
  |---- BCFlickrOperation
            - completion - block executing on finish or error operations


This NSOperation architecture allow great controll over dependant request used by this app
there's some 3 party libraries like FlickrKit but have an excesive use of blocks to preform chain and dependant operation, beside for a single search consume lot of resources and battery. The flickrKit found at https://github.com/devedup/FlickrKit consume 37Mb just searching for a user and get public photos operation.

This app searching a user, getting public photos, sizes of each one and download icon for each item, consume about 12Mb (peaks of 11.6Mb) including filling a tableview.




BCGlobalConfig
--------------------------------------------------------------------------
The BCGlobalConfig class hold common objects for the whole app lifecycle, wrapped in a singleton.




BCNetworkManager
--------------------------------------------------------------------------
BCNetworkManager wrap up BCflickrOperation to handle requests, response, and to abstract the heavy operations involving in a dependants operations, just a completion handler get all the response. theres also methods accepting arrays that avoid make excesive operations on the Viewcontroller class, hiding most of the process of web services.


UI design
---------------------------------------------------------------------------

