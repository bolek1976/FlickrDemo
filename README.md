# FlickrDemo

Simple yet powerfull app written in Objective-C , it allow show public photos with a username key. The app is for demo purpose, it demonstate how to use NSOperation Class to build a complete stack of classes to work with web services.
When the search of an existing user is in progress, tap on the magnifying glass to stop and partial results will be returned. 

Unit test and UI test are available.q

General App architecture notes:


BCBaseOperation
-
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
there's some 3 party libraries 

This app searching a user, getting public photos, sizes of each one and download icon for each item, consume about 12Mb (peaks of 11.6Mb) including filling a tableview.


BCGlobalConfig
-
The BCGlobalConfig class hold common objects for the whole app lifecycle, wrapped in a singleton.




BCNetworkManager
-
BCNetworkManager wrap up BCflickrOperation to handle requests, response, and to abstract the heavy operations involving in a dependants operations, just a completion handler get all the response. theres also methods accepting arrays that avoid make excesive operations on the Viewcontroller class, hiding most of the process of web services.