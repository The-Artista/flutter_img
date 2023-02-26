# flutter_img
a flutter widget that can handle svg, png, jpg image both form asset and network and also support
svg code. For network image it can handel cache.

The following files format are supported:

* JPG (Asset And network with cache)
* PNG (Asset And network with cache)
* JPEG (Asset And network with cache)
* SVG (Asset, network and code)

## Usage

Basic examole

```dart
Img
('https://miro.medium.com/v2/resize:fit:4800/0*bDz2chibrm3B6QZE
'
,fit: BoxFit.fill,
blurHash: 'LGSF|mNH~U?G-oR+Rkt6^%xZD+Ip',
)
,
```

### Paramiters

Param                              | Description                                                                                                                                                                                                                                                                                                                                                             
|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| String src                         | `src` is the one and only positional parameter here, and its requred it will take the asset link, HTTP image link, or SVG code as a string. as you know it takes a string, so for SVG code make sure there is no new line.                                                                                                                                              |
| double? height                     | if you want to set image height explicitly you can pass a height value or it will adjust the height based on image height and screen height                                                                                                                                                                                                                             |
| double? width                      | similar to `height`, `width` parameter also can be used for explicit value                                                                                                                                                                                                                                                                                              |
| BoxShape? shape                    | The `shape` parameter can be use to cahange the shape of iamge.                                                                                                                                                                                                                                                                                                         |
| BoxBorder? border                  | The `border` parameter can be use to add the shape of iamge.                                                                                                                                                                                                                                                                                                            |
| BorderRadiusGeometry? borderRadius | using `borderRadius` You can add border to the image                                                                                                                                                                                                                                                                                                                    |
| EdgeInsetsGeometry? margin         | the `margin` of the image                                                                                                                                                                                                                                                                                                                                               |
| EdgeInsetsGeometry? padding        | the `padding` of the image                                                                                                                                                                                                                                                                                                                                              |
| ColorFilter? colorFilter           | The `colorFilter` allow you to set a color filter over the image                                                                                                                                                                                                                                                                                                        |
| Widget? placeholder                | The `placeholder` parameter allows you to provide any widget as a placeholder before the network image is fully loaded. this parameter only works with png, jpg/jpeg network images. asset images or svg images will not be affected                                                                                                                                    |
| String? blurHash                   | The `blurHash` parameter also allows you to load [blurhash ](https://blurha.sh/) image before the network image is fully loaded. this parameter only works with png, jpg/jpeg network images. asset images or svg images will not be affected. By default if you dont provide `placeholder` blursh will applay. and the default value is `L5H2EC=PM+yV0g-mq.wG9c010J}I` |
| Color? bgColor                     | `bgColor` will set backorund color of the image                                                                                                                                                                                                                                                                                                                         |

## Example

### Network Image with `blurhash`
```dart
Img(
  'https://miro.medium.com/v2/resize:fit:4800/0*bDz2chibrm3B6QZE',
  blurHash: 'LGSF|mNH~U?G-oR+Rkt6^%xZD+Ip',
  width: 400,
  height: 200,
),
```
![network image with blurhash](https://raw.githubusercontent.com/shafi-org/portfolio/master/src/assets/ezgif.com-video-to-gif.gif "network image with blurhash")


### SVG neetwork Image 

```dart
Img(
  'https://raw.githubusercontent.com/shafi-org/portfolio/master/src/assets/flutter-svgrepo-com.svg',
  width: 300,
  height: 300,
)
```

