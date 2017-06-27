# Show Location Image Plugin

This plugin adds location image display functionality to Request and CI web forms in MSM.
If request or CI has specified location having an attached image, new quick menu button appears automatically.
After clicking on that quick menu button an overlay window with the location image is displayed.
It doesn't matter at what location level image is attached. System will display the closest level location image.

# !!! IMPORTANT !!!:
Since MSM system doesn't have any MSM location data web services by default, MSM Web Service Extensions are required (not included here).
Only if/when new location api methods will be implemented in MSM system this package could be used in your systems.
Please feel free to contact Marval Baltic if you would like to see it working.

## Compatible Versions

| Plugin  | MSM             |
|---------|-----------------|
| 1.3.0   | 14.3.1 - 14.5.1 |

## Installation

Please see your MSM documentation for information on how to install plugins.

Once the plugin has been installed as plugin parameters you need to specify:
* Location Element Selector Query - selector query used to find location element in a layout
* MSM WSE Address - MSM Web Service Extensions (not available publicly) address
* MSM WSE User Name - MSM Web Service Extensions user name (can be encrypted WSE specific way)
* MSM WSE Password - MSM Web Service Extensions password (can be encrypted WSE specific way)

## Usage

The plugin can be launched from the quick menu on a new or existing request or CI forms.

## Contributing

 Any feedback is very welcome.