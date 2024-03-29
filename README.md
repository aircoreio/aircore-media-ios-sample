# AircoreMediaSample

AircoreMediaSample is a sample app that gives an example of how to use the [AircoreMedia-iOS](https://github.com/aircoreio/aircore-media-ios) SDK to connect real-time audio and video streams. 

# Building

### Device

Build AircoreMediaSample with Xcode 13.2.1 or greater, to a device running iOS 14 or greater. Building to a device requires setting the development team in the project's Signing & Capabilites tab. A provisioning profile should be automatically created for this sample app using the selected development team.

### Simulator

AircoreMediaSample will currently run only on x86_64 simulators.

# Creating an AircoreMedia app and Publishable API Key 

Refer to the [documentation](https://docs.aircore.io/authentication) for an understanding of creating an app and API Keys. This sample app provides an example of using a Publishable API Key to create and connect to a Channel. Replace the placeholder API key listed in ChannelViewModel with your own Publishable API Key: `let publishableAPIKey = "pub_somePublishableAPIKey"`. 

# The AircoreMediaSample UI
This sample app has a very simple list UI that has various sections relating to a Channel
- Channel Configuration
...Configure a Channel with a given Channel ID and User ID, and join or stop the channel
- Channel Status
...This section lists the currently connected Channel's ID, the Channel's active state, and a termination cause if the Channel has been terminated
- Local Stream
...If the Channel has been joined, LocalStream properties will be shown, including a button for starting and stopping the LocalStream, a switch for an "audio-only" mode where video is not published, a button for muting the stream's audio that will turn green when voice activity is detected, a button for muting the stream's video, and displays for the connection state and termination cause.
- Remote Streams
...If the Channel has currently connected RemoteStream objects, the section shows a row for each connected RemoteStream, with an indicator for the local and remote audio mute state, the voice activity, the local and remote video mute state, the RemoteStream's user ID, and the RemoteStream's connection state.
- Video View
...If publishing a LocalStream with video, the preview of your publish stream will be displayed with an indicator if video is muted. RemoteStream video streams will also be displayed in a horizontally scrollable set of tiles, with indicators if the RemoteStream video is muted.   
