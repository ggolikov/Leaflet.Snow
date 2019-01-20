# Leaflet.Snow

WebGL snow animation for Leaflet maps. Extends L.Polygon.

## [Demo](https://ggolikov.github.io/Leaflet.Snow)

## Installation
works with leaflet@1.x.x
```
npm install leaflet
npm install leaflet-snow
```

```javascript
import L from 'leaflet';
import 'leaflet-snow';
```

## Usage

```javascript
let map = L.map(...);

let points = [[latlngs], [latlngs], ...],
    options = {
        speed: 100,
        layersCount: 1,
        density: 1,
        size: 10,
        color: 'Oxffffff',
        opacity: 1
    },
    snow = L.snow(points, options).addTo(map);
```

## API reference
### Factory
Factory|Description
-------|-----------
L.snow(`LatLng[]` _latlngs_, `options` _options?_)| Create snow animation inside (multi)polygon with given latlngs.
### Options
Option|Type|Default|Range|Description
----|----|----|----|----
speed|`Number`|50|0-Infinity|Snow speed (px/s)
layersCount|`Number`|1|1-5| Number of snow layers. Snowflakes increase their size and decrease their density and  speed from back to top layers
density|`Number`|1|1-5|Density coefficient of bottom snow layer
size|`Number`|10|1- Infinity |Snowflake size (px) at front layer
color|`String`|`Oxa6b3e9`| |Snow color hex value
opacity|`Number`|1|0-1|Snow opacity

### Methods
Method|Description
------|-------
setSpeed(`Number`)|Sets snow speed (px/s)
setLayersCount(`Number`)|Sets snow layers count (1-5)
setDensity(`Number`)|Sets snow back layer density (1-5)
setSize(`Number`)|Sets snowflake size at front layer (px)
setColor(`hex string`)|Sets snow color
setOpacity(`Number`)|Sets snow opacity (0-1)

## [License](https://opensource.org/licenses/MIT)
